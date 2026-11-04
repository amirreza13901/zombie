extends Node2D


@onready var pipe: Node2D = $pipe
@onready var player: CharacterBody2D = $Player
@onready var spawn_left: Marker2D = $SpawnLeft


func _ready() -> void:
	if GameState.starting_dial:
	# Create the dialogue data
		var intro_dialogue = [
			{ "speaker": "NARATOR", "line": "The air is thick with the smell of antiseptic and something... else." },
			{ "speaker": "NARATOR", "line": "You try to move, but your body feels heavy. A dull ache pulses in your side." },
			{ "speaker": "NARATOR", "line": "A low groan echoes from the hallway. You are not alone." }
		]
		
		# Immediately trigger the dialogue. 
		# We pass 'true' so the DialogueManager knows to handle the fade from black.
		DialogueManager.start_dialogue(intro_dialogue, true)
		GameState.starting_dial = false
	if GameState.spawn_door =='left':
		DialogueManager.clear_black_screen()
		player.global_position = spawn_left.global_position
func _process(delta: float) -> void:
	if GameState.has_melee_dial:
			var pipe_dial = [
		{ "speaker": "Alex", "line": "nice a pipe" 
		}]
			DialogueManager.start_dialogue(pipe_dial, false)
			GameState.has_melee_dial = false
			GameState.has_melee = true
			await DialogueManager.dialogue_finished
			pipe.queue_free()


func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		GameState.spawn_door = "right"
		get_tree().change_scene_to_file("res://room2.tscn")




	
