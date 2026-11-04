extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysGame.gd"

# Drag your Player node into this slot in the Inspector
#@export var player: CharacterBody2D
# Drag your room_1.tscn into this slot in the Inspector
@export var starting_room: PackedScene

func _ready():
	# 1. Reset the system
	MetSys.reset_state()
	
	# 2. Initialize save data (empty for new game)
	MetSys.set_save_data({})
	
	# 3. Load the starting room
	if starting_room:
		var room_instance = starting_room.instantiate()
		add_child(room_instance)
		
	add_module("RoomTransitions.gd") 
		
		# Optional: Move the player to the center of the room when it spawns
		#if player:
			#player.global_position = Vector2(200, 200)

func _process(delta):
	# 4. Every frame, tell MetSys where the player is.
	# This is what tracks which room you are in and updates the map!
	if player:
		MetSys.set_player_position(player.global_position)
