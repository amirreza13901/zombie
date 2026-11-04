extends Node2D

var in_pipe:bool = false

func _ready() -> void:
	$AnimatedSprite2D.visible = false


func _process(delta: float) -> void:
	if in_pipe:
		if Input.is_action_just_pressed('ui_down'):
			GameState.has_melee_dial = true

			

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		$AnimatedSprite2D.visible = true



func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group('player'):
		$AnimatedSprite2D.visible = false


func _on_pickuparea_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		in_pipe = true
		
		


func _on_pickuparea_body_exited(body: Node2D) -> void:
	if body.is_in_group('player'):
		in_pipe = false
