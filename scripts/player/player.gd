extends CharacterBody2D

enum player_state {
	idle,
	walk,
	jump,
	fall,
	dash,
	hurt
}

var stats = {
	"max_hp": 100,
	"damage": 10
}

var current_state = player_state.idle
var gravity = 700
var jump_force = -350
var speed = 200
var air_speed = 150  # Reduced speed while in the air
var dash_speed = 550
var can_dash = true
var is_hurt = false
var is_invincible = false

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
		player_state.hurt:
			handle_hurt()


	#print(current_state)
	# Apply gravity
	if !is_on_floor():
		velocity.y += gravity * delta

	# Apply movement
	move_and_slide()
	
	if Input.is_action_just_pressed("fire"):
		fire()

func handle_idle():
	$AnimatedSprite2D.play("idle")
	velocity.x = 0  # Stop horizontal movement
	gravity = 700
	if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
		current_state = player_state.walk
	elif Input.is_action_just_pressed("jump") and is_on_floor():
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
	if velocity.y > 0:
		current_state = player_state.fall

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
	gravity = 1500
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
		
	if velocity.y > 0:  # If moving downward
		current_state = player_state.fall
		
	if Input.is_action_pressed("dash"):
		if can_dash:
			current_state = player_state.dash
		else:
			pass

func handle_dash():
	velocity.y = 0
	print("dashing")
	$AnimatedSprite2D.play("dash")
	if $DashDuration.is_stopped():
		$DashDuration.start(0.3)
	if $AnimatedSprite2D.flip_h:
		velocity.x = -dash_speed
	else:
		velocity.x = dash_speed

func handle_hurt():
	if !is_hurt:
		is_hurt = true
		velocity.x = 0
		$AnimatedSprite2D.play("hurt")
		$HurtDuration.start(1)
		print("hurt duration starts")


func _on_dash_duration_timeout() -> void:
	if !is_hurt:
		print("Dash timer finished")  # Logs when the timer ends
		current_state = player_state.idle
	can_dash = false
	$DashCooldown.start(0.75)


func _on_dash_cooldown_timeout() -> void:
	print("dash cooldowned")
	can_dash = true


func _on_hurtbox_area_entered(hurtbox) -> void:
	var damage_amount = hurtbox.get_parent().damage
	if !is_invincible:
		if stats["max_hp"] <= 0:
			die()
		else:
			stats["max_hp"] -= damage_amount
			print(stats["max_hp"])
			current_state = player_state.hurt
	else:
		pass

func die():
	queue_free()

func fire():
	var bullet_scene = preload("res://scenes/statics/bullet.tscn")
	var bullet = bullet_scene.instantiate()
	bullet.damage = stats["damage"]
	bullet.position = global_position
	if $AnimatedSprite2D.flip_h:
		bullet.direction = Vector2(-1, 0)
	else:
		bullet.direction = Vector2(1, 0)
	get_parent().add_child(bullet)
	print("fire!")

func _on_hurt_duration_timeout() -> void:
	print("hurt duration finished")
	is_hurt = false
	is_invincible = true
	current_state = player_state.idle
	$InvincibilityDuration.start(2)


func _on_invincibility_duration_timeout() -> void:
	is_invincible = false
	print("invincibility finished")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("jump"):
		if velocity.y < 0:
			velocity.y *= 0.7
	
