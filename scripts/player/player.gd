extends CharacterBody2D

const gravity = 500
var dash_speed = 700
var jump_strength = 300
var speed = 200
var is_dashing = false 
var can_dash = true
var is_facing_left = false
var is_jumping = false
var is_crouching = false
var crouch_speed = 100
var is_crawling = false


func _physics_process(delta: float) -> void:
	print($AnimatedSprite2D.animation)
	print("is_crouching: ", is_crouching)
	print("is_crawling: ", is_crawling)
	get_input(delta)
	move_and_slide()

func get_input(delta: float):
	if is_dashing:
		return  # Skip normal movement during dash

	var direction = Input.get_axis("left", "right")
	velocity.x = 0
	if is_on_floor() and !is_crouching:
		if is_facing_left and !direction:
			$AnimatedSprite2D.play("idle_left")
		elif !is_facing_left and !direction:
			$AnimatedSprite2D.play("idle_right")
	
	if direction:
		if !is_crouching:
			velocity.x = direction * speed
		elif is_crouching:
			velocity.x = direction * crouch_speed
			crawl()
		if velocity.x > 0 and is_on_floor():
			$AnimatedSprite2D.play("walk_right")
			is_facing_left = false
		elif velocity.x < 0 and is_on_floor():
			$AnimatedSprite2D.play("walk_left")
			is_facing_left = true
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.x > 0:
			is_facing_left = false
		elif velocity.x < 0: 
			is_facing_left = true
		if is_facing_left:
			$AnimatedSprite2D.play("jump_left")
		else:
			$AnimatedSprite2D.play("jump_right")
		
	if Input.is_action_just_pressed("dash"):
		dash()
	if Input.is_action_pressed("crouch"):
		#if direction:
			#crawl()
		#else:
			#crouch()
		crouch()
	if Input.is_action_just_released("crouch"):
		stop_crouching()
	if Input.is_action_pressed("jump"):
		jump()

func jump():
	if is_on_floor():
		is_dashing = false
		is_jumping = true
		velocity.y -= jump_strength
		
		if is_facing_left:
			$AnimatedSprite2D.play("jump_left")
			print("jumping left")
		else:
			$AnimatedSprite2D.play("jump_right")
			print("jumping right")
			
			
func crouch():
	if is_on_floor():
		is_crouching = true
		is_crawling = false
		if is_crouching and !is_crawling:
			if is_facing_left:
				$AnimatedSprite2D.play("crouch_left")
			elif !is_facing_left:
				$AnimatedSprite2D.play("crouch_right")
func crawl():
	if is_on_floor():
		is_crawling = true
		is_crouching = true
		if is_facing_left:
			if $AnimatedSprite2D.animation != "crawl_left" or !$AnimatedSprite2D.is_playing():
				$AnimatedSprite2D.play("crawl_left")
		else:
			if $AnimatedSprite2D.animation != "crawl_right" or !$AnimatedSprite2D.is_playing():
				$AnimatedSprite2D.play("crawl_right")
func stop_crouching():
	is_crawling = false
	is_crouching = false
func dash():
	if can_dash and !is_crouching:
		is_dashing = true
		velocity.y = 0
		velocity.x = -dash_speed if is_facing_left else dash_speed
		$AnimatedSprite2D.play("dash_left" if is_facing_left else "dash_right")
		# Start dash timer
		$DashDuration.start(0.3)

func _on_dash_duration_timeout() -> void:
	is_dashing = false
	can_dash = false
	velocity.x = 0  # Stop horizontal movement after dash
	$DashCooldown.start(1)
	if !is_on_floor():
		$AnimatedSprite2D.play("falling_down")

func _on_dash_cooldown_timeout() -> void:
	can_dash = true
	print("dash cooldowned")
