extends CanvasLayer

# Remove any @export lines and use this @onready path:
@export var heartbeat:ColorRect

func _ready():
	# 🪄 CRUCIAL: This allows the menu to work even when the game is paused!
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	# Check if we pressed Tab
	if event.is_action_pressed("toggle_menu"):
		visible = !visible 
		get_tree().paused = visible
		if visible:
			update_health_display()

func update_health_display():
	var hp = GameState.player_health
	var max_hp = GameState.max_health
	var hp_percent = float(hp) / float(max_hp)
	

	# 🪄 Change ".modulate" to ".color"
	if hp_percent > 0.6:
		heartbeat.color = Color(0, 1, 0) # GREEN
	elif hp_percent > 0.3:
		heartbeat.color = Color(1, 1, 0) # YELLOW
	else:
		heartbeat.color = Color(1, 0, 0) # REDD
