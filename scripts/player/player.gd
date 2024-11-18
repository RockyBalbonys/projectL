extends CharacterBody2D

const gravity = 400
var dash_speed = 500
var jump_strength = 200
var speed = 100
var is_dashing = false 
var can_dash = true
var is_facing_left = false
var is_jumping = false

func _physics_process(delta: float) -> void:
	
	get_input(delta)
	move_and_slide()
	print($AnimatedSprite2D.animation)

func get_input(delta: float):
	if is_dashing:
		return  # Skip normal movement during dash

	var direction = Input.get_axis("left", "right")
	velocity.x = 0
	if is_on_floor():
		if is_facing_left and !direction:
			$AnimatedSprite2D.play("idle_left")
		elif !is_facing_left and !direction:
			$AnimatedSprite2D.play("idle_right")
	
	if direction:
		velocity.x = direction * speed
		if velocity.x > 0 and is_on_floor():
			$AnimatedSprite2D.play("walk_right")
			is_facing_left = false
		elif velocity.x < 0 and is_on_floor():
			$AnimatedSprite2D.play("walk_left")
			is_facing_left = true

	# Jump
	if is_on_floor() and Input.is_action_pressed("jump"):
			jump()
			


	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if Input.is_action_just_pressed("dash"):
		dash()

func jump():
	is_dashing = false
	is_jumping = true
	velocity.y -= jump_strength
	$AnimatedSprite2D.play("jump_right")
	print("jumping")

func dash():
	if can_dash:
		is_dashing = true

		# Apply dash speed
		velocity.x = -dash_speed if is_facing_left else dash_speed
		$AnimatedSprite2D.play("dash_left" if is_facing_left else "dash_right")
		
		# Start dash timer
		$DashDuration.start(0.3)

func _on_dash_duration_timeout() -> void:
	is_dashing = false
	can_dash = false
	velocity.x = 0  # Stop horizontal movement after dash
	$DashCooldown.start(1)
	print("dash duration finished")

func _on_dash_cooldown_timeout() -> void:
	can_dash = true
	print("dash cooldowned")
