extends CharacterBody2D

const gravity = 800
var jump_strength = 600
var speed = 400

# Checks if the dash cooldown is over
var dash_cooldown_over = true

# Boolean for checking if the player is facing left or not
var left = false

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	get_input(delta)
	move_and_slide()

func get_input(delta: float):
	# Gets rid of acceleration
	velocity.x = 0
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y -= jump_strength

	if Input.is_action_pressed("left"):
		if velocity.x > -400:
			velocity.x -= speed
			left = true
	elif Input.is_action_pressed("right"):
		if velocity.x < 400:
			velocity.x += speed
			left = false

	if Input.is_action_just_pressed("dash"):
		dash()

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

func dash():
	if left:
		if dash_cooldown_over == false:
			return
		velocity.x -= 2000 * 6
		dash_cooldown_over = false
		await get_tree().create_timer(0.5).timeout
		dash_cooldown_over = true
	else:
		if dash_cooldown_over == false:
			return
		velocity.x += 2000 * 6
		dash_cooldown_over = false
		await get_tree().create_timer(0.5).timeout
		dash_cooldown_over = true
