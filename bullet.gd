extends Area2D

var speed = 800.0
var direction = 1 # 1 for right, -1 for left

func _physics_process(delta):
	# Move the bullet forward
	position.x += speed * direction * delta

func _on_body_entered(body):
	# If it hits a zombie, damage it and destroy the bullet
	if body.is_in_group("enemies"):
		body.take_damage(20) # Guns do more damage than swords!
		queue_free() # Destroy the bullet

func _on_visible_on_screen_notifier_2d_screen_exited():
	# Destroy the bullet if it flies off-screen so the game doesn't lag
	queue_free()
