extends Node2D
@onready var zombie: CharacterBody2D = $zombie


func _ready() -> void:
	if GameState.zombie_defeated:
		zombie.queue_free()
	else:
		$area2d/CollisionShape2D.disabled=true
		
		

func _process(delta: float) -> void:
	if GameState.zombie_defeated:
		$StaticBody2D/CollisionShape2D.disabled=false
func _on_static_body_2d_body_entered(body: Node2D) -> void:
	if GameState.zombie_defeated:
		if body.is_in_group("player"):
			GameState.spawn_door = "left"
			get_tree().change_scene_to_file("res://room1.tscn")
