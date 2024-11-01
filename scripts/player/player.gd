extends CharacterBody2D

const gravity = 500
var jump_strength = 500
var speed = 400
var friction = 1.2

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	get_input(delta)
	move_and_slide()

func get_input(delta: float):
	velocity.x = 0
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y -= jump_strength

	if Input.is_action_pressed("left"):
		if velocity.x > -400:
			velocity.x -= speed
	elif Input.is_action_pressed("right"):
		if velocity.x < 400:
			velocity.x += speed
	

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
