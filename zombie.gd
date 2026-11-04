extends CharacterBody2D

enum State { LURK, CHASE }
var current_state: State = State.LURK

const LURK_SPEED = 200
const CHASE_SPEED = 400
const GRAVITY = 980.0

var player: CharacterBody2D = null
var dir: int = 1
var health: int = 100
var knockback_timer: float = 0.0 
var turn_cooldown: float = 0.0 
var is_dead: bool = false

@onready var ledge_ray = $LedgeRay
@onready var hurt_box: Area2D = $HurtBox

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if is_dead: 
		GameState.zombie_defeated=true
		return

	# 1. Apply Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# 2. 🪄 THE MISSING DAMAGE CODE
	# Check every frame if the player is inside the Hurtbox
	for body in $HurtBox.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(10, self)

	# 3. Cooldowns & State Machine
	if knockback_timer > 0:
		knockback_timer -= delta
		velocity.x = move_toward(velocity.x, 0, 1000 * delta)
	elif turn_cooldown > 0:
		turn_cooldown -= delta
		# 🪄 THE HESITATION FIX: Keep walking while in cooldown!
		velocity.x = dir * LURK_SPEED 
	else:
		match current_state:
			State.LURK:
				_lurk_state()
			State.CHASE:
				_chase_state()

	# 4. Flip sprite
	if velocity.x > 0 and knockback_timer <= 0:
		$Sprite2D.flip_h = false
	elif velocity.x < 0 and knockback_timer <= 0:
		$Sprite2D.flip_h = true
		
	# 5. Flip the RayCast (Keep it slightly in front: X = 10)
	ledge_ray.position.x = 10 * dir 
	ledge_ray.target_position.x = abs(ledge_ray.target_position.x) * dir

	move_and_slide()

func _lurk_state():
	# Check for ledge FIRST
	if is_on_floor() and not ledge_ray.is_colliding():
		dir *= -1
		velocity.x = dir * LURK_SPEED # 🪄 Instantly push away from the edge
		turn_cooldown = 0.4 # Wait a moment before checking again
		global_position.x += dir * 5 # Nudge away from the edge
		
	# If safe, walk normally
	velocity.x = dir * LURK_SPEED
	
	# Check for wall
	if is_on_wall():
		dir *= -1
		velocity.x = dir * LURK_SPEED
		turn_cooldown = 0.4

func _chase_state():
	if player:
		var distance_x = abs(player.global_position.x - global_position.x)
		
		# Stop shaking when close
		if distance_x < 25:
			velocity.x = 0 
		else:
			dir = sign(player.global_position.x - global_position.x)
			velocity.x = dir * CHASE_SPEED

# --- DETECTION AREA SIGNAL ---
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		current_state = State.CHASE

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		current_state = State.LURK
		

func take_damage(amount: int):
	if is_dead:return
	health -= amount
	
	$Sprite2D.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	if not is_dead:
		$Sprite2D.modulate = Color(1, 1, 1)
	
	if health <= 0:
		is_dead = true
		queue_free()
		return
		
	if player:
		knockback_timer = 0.3 
		var knockback_dir = sign(global_position.x - player.global_position.x)
		velocity.x = knockback_dir * 300 
		velocity.y = -200 
