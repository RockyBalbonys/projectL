extends targeting_enemies

func _ready() -> void:
	super()
	#$Attack1/CollisionShape2D.disabled = true

func _physics_process(delta: float) -> void:
	super(delta)
	#print("animation: ", $AnimatedSprite2D.animation)
	if direction == 1:
		$Attack1/CollisionShape2D.position = Vector2(40, 12)
		$FrontVision.target_position = Vector2(70,0)
	else:
		$Attack1/CollisionShape2D.position = Vector2(-40, 12)
		$FrontVision.target_position = Vector2(-70,0)

func handle_attack():
	if can_attack:
		velocity.x = 0
		if !is_attacking and player_detected:
			$AnimatedSprite2D.play("attack")
			print("im attacking!")
			if $AnimatedSprite2D.frame == 4:
				$Attack1/CollisionShape2D.disabled = false
			else:
				$Attack1/CollisionShape2D.disabled = true
	else: #waiting for attack cooldown
		current_state = enemy_state.approach
		#$AnimatedSprite2D.play("walking")

func _on_hurtbox_area_entered(area: Area2D) -> void:
	take_damage(area.get_parent().stats["damage"])
	print("damage taken: ", area.get_parent().stats["damage"])


func _on_attack_cooldown_timeout() -> void:
	can_attack = true
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "attack":
		can_attack = false
		is_attacking = false
		if $FrontVision.is_colliding():
			player_detected = true
		else:
			player_detected = false
		if $AttackCooldown.is_stopped():
			$AttackCooldown.start(attack_cooldown_duration)
		
