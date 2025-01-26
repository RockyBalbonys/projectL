extends CharacterBody2D

enum player_state {
	idle,
	walk,
	jump,
	doublejump,
	fall,
	dash,
	hurt,
	attack,
	airattack
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
var can_doublejump = false

func _physics_process(delta: float) -> void:
	
	match current_state:
		player_state.idle:
			handle_idle()
		player_state.walk:
			handle_walk()
		player_state.jump:
			handle_jump()
		player_state.doublejump:
			handle_doublejump()
		player_state.fall:
			handle_fall()
		player_state.dash:
			handle_dash()
		player_state.hurt:
			handle_hurt()
		player_state.attack:
			handle_attack()
		player_state.airattack:
			handle_air_attack()


	#print(gravity)
	
	# Apply gravity
	if !is_on_floor():
		velocity.y += gravity * delta

	# Apply movement
	move_and_slide()

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
	elif Input.is_action_just_pressed("attack"):
		current_state = player_state.attack

# Walk state behavior
func handle_walk():
	$AnimatedSprite2D.play("walk")
	var direction = Input.get_axis("left", "right")  # -1 for left, 1 for right
	velocity.x = direction * speed
	if !Input.is_action_pressed("right") and !Input.is_action_pressed("left"):
		current_state = player_state.idle
	elif Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force  # Apply jump force
		current_state = player_state.jump
	elif Input.is_action_pressed("dash"):
		if can_dash:
			current_state = player_state.dash
		else:
			pass
	elif Input.is_action_just_pressed("attack"):
		velocity.x = 0
		current_state = player_state.attack
	if velocity.y > 0:
		current_state = player_state.fall

	if direction < 0:  # Moving left
		$AnimatedSprite2D.flip_h = true
		$Hitbox/CollisionShape2D.position = Vector2(-24.5, -5.0)
		
	elif direction > 0:  # Moving right
		$AnimatedSprite2D.flip_h = false
		$Hitbox/CollisionShape2D.position = Vector2(24.5, -5.0)

# Jump state behavior
func handle_jump():
	var direction = Input.get_axis("left", "right")  # -1 for left, 1 for right
	$AnimatedSprite2D.play("jump")
	can_doublejump = true
	handle_air_movement()
	if velocity.y > 0:  # If moving downward
		current_state = player_state.fall

func handle_doublejump():
	print("double jumped!")
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
	
	if Input.is_action_just_pressed("jump") and can_doublejump:
		gravity = 700
		can_doublejump = false
		velocity.y = jump_force
		current_state = player_state.doublejump
		
	if Input.is_action_pressed("dash"):
		if can_dash:
			current_state = player_state.dash
		else:
			pass
	
	if Input.is_action_just_pressed("attack"):
		current_state = player_state.airattack

func handle_attack():
	$AnimatedSprite2D.play("attack1")
	$Hitbox.monitoring = true
	$Hitbox/CollisionShape2D.disabled = false

func handle_air_attack():
	$AnimatedSprite2D.play("attack1")
	$Hitbox.monitoring = true
	$Hitbox/CollisionShape2D.disabled = false
	

func _on_animated_sprite_2d_animation_finished() -> void:
	$Hitbox.monitoring = false
	$Hitbox/CollisionShape2D.disabled = true
	current_state = player_state.idle

func handle_dash():
	velocity.y = 0
	$AnimatedSprite2D.play("dash")
	if $DashDuration.is_stopped():
		$DashDuration.start(0.2)
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
	
