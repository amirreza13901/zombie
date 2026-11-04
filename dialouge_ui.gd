extends CanvasLayer

@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var dialogue_box: Control = $UIRoot/DialogueBox
@onready var speaker_name: Label = $UIRoot/DialogueBox/Panel/Margin/VBox/SpeakerName
@onready var dialogue_text: RichTextLabel = $UIRoot/DialogueBox/Panel/Margin/VBox/DialogueText
@onready var continue_arrow: Label = $UIRoot/DialogueBox/Panel/Margin/VBox/ContinueArrow
@onready var options_container: VBoxContainer = $UIRoot/DialogueBox/Panel/Margin/VBox/OptionsContainer

# Signal to tell other scripts when the conversation is over
signal dialogue_finished

@export var typewriter_speed: float = 0.04
@export var arrow_blink_speed: float = 0.5

var _current_index: int = 0
var _is_typing: bool = false
var _active_tween: Tween
var _arrow_tween: Tween
var _input_cooldown: bool = false
var _current_dialogue: Array = []
var _is_transitioning: bool = false
var _is_waiting_for_choice: bool = false
signal option_triggered(action_name: String)

func _ready() -> void:
	# Start completely black when the game launches so there is no flash
	fade_overlay.modulate.a = 1.0 
	dialogue_box.visible = false
	dialogue_text.text = ""
	continue_arrow.visible = false
	options_container.visible = false
	set_process_unhandled_input(false)

func start_dialogue(new_dialogue: Array, fade_from_black: bool = false) -> void:
	_current_dialogue = new_dialogue
	_current_index = 0
	_is_transitioning = true 
	
	_set_player_input_enabled(false)
	set_process_unhandled_input(false)
	
	if fade_from_black:
		fade_overlay.modulate.a = 1.0 
		dialogue_box.visible = false
		
		await get_tree().create_timer(0.5).timeout
		
		_active_tween = create_tween()
		_active_tween.tween_property(fade_overlay, "modulate:a", 0.0, 1.0)
		await _active_tween.finished
		
		dialogue_box.visible = true
		_show_line(0)
	else:
		dialogue_box.visible = true
		dialogue_box.modulate.a = 0.0
		var pop_tween = create_tween()
		pop_tween.tween_property(dialogue_box, "modulate:a", 1.0, 0.2)
		await pop_tween.finished
		_show_line(0)
		
	# Wait a tiny fraction of a second to let the fade completely finish, then unlock
	await get_tree().process_frame
	_is_transitioning = false 
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	# If we are fading, waiting for a choice, or on cooldown, IGNORE input
	if _is_transitioning or _input_cooldown or _is_waiting_for_choice: 
		return
		
	if event.is_action_pressed("attack") or (event is InputEventMouseButton and event.pressed):
		_input_cooldown = true
		_advance_dialogue()

func _show_line(index: int) -> void:
	if index >= _current_dialogue.size():
		_end_dialogue()
		return

	var entry = _current_dialogue[index]
	speaker_name.text = entry.get("speaker", "")
	dialogue_text.text = entry.get("line", "")
	dialogue_text.visible_ratio = 0.0
	continue_arrow.visible = false
	
	# Hide options initially
	options_container.visible = false
	_is_waiting_for_choice = false
	for child in options_container.get_children():
		child.queue_free()
	
	_is_typing = true

	var char_count = dialogue_text.get_total_character_count()
	var duration = maxf(char_count * typewriter_speed, 0.2)

	_active_tween = create_tween()
	_active_tween.tween_property(dialogue_text, "visible_ratio", 1.0, duration)
	_active_tween.finished.connect(_on_typing_finished)

func _on_typing_finished() -> void:
	_is_typing = false
	
	var current_entry = _current_dialogue[_current_index]
	
	# Check if this line has options
	if current_entry.has("options"):
		_show_options(current_entry["options"])
	else:
		_show_continue_arrow()

func _show_options(options_data: Array) -> void:
	_is_waiting_for_choice = true
	options_container.visible = true
	continue_arrow.visible = false
	
	for i in range(options_data.size()):
		var opt = options_data[i]
		var btn = Button.new()
		btn.text = opt.get("text", "Option")
		
		btn.add_theme_color_override("font_color", Color("#e8e8e8"))
		btn.add_theme_color_override("font_hover_color", Color("#c9a227"))
		btn.add_theme_color_override("font_focus_color", Color("#c9a227"))
		
		# PASS THE WHOLE OPTION DICTIONARY HERE
		btn.pressed.connect(_on_option_selected.bind(opt)) 
		options_container.add_child(btn)
		
		if i == 0:
			btn.grab_focus()

func _on_option_selected(option_data: Dictionary) -> void:
	_is_waiting_for_choice = false
	options_container.visible = false
	
	# Clear the buttons
	for child in options_container.get_children():
		child.queue_free()
		
	# 1. Check if this option has a trigger action attached to it
	if option_data.has("trigger"):
		option_triggered.emit(option_data["trigger"])
		
	# 2. Move to the next line
	_current_index = option_data.get("next_index", 0)
	_show_line(_current_index)

func _show_continue_arrow() -> void:
	continue_arrow.visible = true
	continue_arrow.modulate.a = 1.0
	if _arrow_tween and _arrow_tween.is_valid():
		_arrow_tween.kill()
	_arrow_tween = create_tween().set_loops()
	_arrow_tween.tween_property(continue_arrow, "modulate:a", 0.0, arrow_blink_speed)
	_arrow_tween.tween_property(continue_arrow, "modulate:a", 1.0, arrow_blink_speed)

func _hide_continue_arrow() -> void:
	if _arrow_tween and _arrow_tween.is_valid():
		_arrow_tween.kill()
	continue_arrow.visible = false

func _advance_dialogue() -> void:
	# If options are on screen, don't let the player skip them
	if _is_waiting_for_choice:
		return

	if _is_typing:
		if _active_tween and _active_tween.is_valid():
			_active_tween.kill()
		dialogue_text.visible_ratio = 1.0
		_on_typing_finished()
		await get_tree().process_frame
		_input_cooldown = false
		return

	_hide_continue_arrow()
	_current_index += 1
	_show_line(_current_index)
	await get_tree().process_frame
	_input_cooldown = false

func _end_dialogue() -> void:
	set_process_unhandled_input(false) 
	
	_hide_continue_arrow()
	_active_tween = create_tween()
	_active_tween.tween_property(dialogue_box, "modulate:a", 0.0, 0.3)
	await _active_tween.finished
	
	dialogue_box.visible = false
	_set_player_input_enabled(true)
	dialogue_finished.emit()

func _set_player_input_enabled(enabled: bool) -> void:
	if not get_tree().has_group("player"): return
	for player in get_tree().get_nodes_in_group("player"):
		if player.has_method("set_input_enabled"):
			player.set_input_enabled(enabled)

func clear_black_screen() -> void:
	if fade_overlay.modulate.a > 0.0:
		var tween = create_tween()
		tween.tween_property(fade_overlay, "modulate:a", 0.0, 0.5) 
