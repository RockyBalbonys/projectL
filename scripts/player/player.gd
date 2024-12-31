extends CharacterBody2D

enum player_state {
	idle,
	walk,
	jump,
	fall,
	dash
}

var current_state = player_state.idle
var gravity = 700
var jump_force = -350
var speed = 200
var air_speed = 150  # Reduced speed while in the air
var dash_speed = 550
var can_dash = true

func _physics_process(delta: float) -> void:
	match current_state:
		player_state.idle:
			handle_idle()
		player_state.walk:
			handle_walk()
		player_state.jump:
			handle_jump()
		player_state.fall:
			handle_fall()
		player_state.dash:
			handle_dash()

	# Apply gravity
	if !is_on_floor():
		velocity.y += gravity * delta

	# Apply movement
	move_and_slide()

	print("State: ", current_state)
	print("is on floor: ", is_on_floor())
	print($AnimatedSprite2D.flip_h)

func handle_idle():
	$AnimatedSprite2D.play("idle")
	velocity.x = 0  # Stop horizontal movement
	if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
		current_state = player_state.walk
	elif Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_force  # Apply jump force
		current_state = player_state.jump
	elif Input.is_action_pressed("dash"):
		if can_dash:
			current_state = player_state.dash
		else:
			pass

# Walk state behavior
func handle_walk():
	$AnimatedSprite2D.play("walk")
	var direction = Input.get_axis("left", "right")  # -1 for left, 1 for right
	velocity.x = direction * speed
	if !Input.is_action_pressed("right") and !Input.is_action_pressed("left"):
		current_state = player_state.idle
	elif Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_force  # Apply jump force
		current_state = player_state.jump
	elif Input.is_action_pressed("dash"):
		if can_dash:
			current_state = player_state.dash
		else:
			pass

	if direction < 0:  # Moving left
		$AnimatedSprite2D.flip_h = true
	elif direction > 0:  # Moving right
		$AnimatedSprite2D.flip_h = false

# Jump state behavior
func handle_jump():
	var direction = Input.get_axis("left", "right")  # -1 for left, 1 for right
	$AnimatedSprite2D.play("jump")
	handle_air_movement()
	if velocity.y > 0:  # If moving downward
		current_state = player_state.fall


# Fall state behavior
func handle_fall():
	$AnimatedSprite2D.play("fall")
	handle_air_movement()
	if is_on_floor():  # Transition back to idle when landing
		current_state = player_state.idle

# Handle movement while in the air (jump or fall)
func handle_air_movement():
	var direction = Input.get_axis("left", "right")
	velocity.x = direction * air_speed
	if direction < 0:  # Moving left
		$AnimatedSprite2D.flip_h = true
	elif direction > 0:  # Moving right
		$AnimatedSprite2D.flip_h = false
	
	if Input.is_action_pressed("dash"):
		current_state = player_state.dash

func handle_dash():
	$AnimatedSprite2D.play("dash")
	velocity.y = 0
	if $DashDuration.is_stopped():
		$DashDuration.start(0.3)
	if $AnimatedSprite2D.flip_h:
		velocity.x = -dash_speed
	else:
		velocity.x = dash_speed

func _on_dash_duration_timeout() -> void:
	print("Dash timer finished")  # Logs when the timer ends
	current_state = player_state.idle
	can_dash = false
	$DashCooldown.start(3)


func _on_dash_cooldown_timeout() -> void:
	print("dash cooldowned")
	can_dash = true
