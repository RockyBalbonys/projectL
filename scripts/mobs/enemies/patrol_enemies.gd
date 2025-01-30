extends enemies
class_name patrol_enemies

enum enemy_state {
	idle,
	patrol
}


var current_state = enemy_state.idle

func _physics_process(delta: float) -> void:
	match current_state:
			enemy_state.idle:
				handle_idle()
			enemy_state.patrol:
				handle_patrol()
		
	if !is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

func handle_idle():
	if is_on_floor():
		current_state = enemy_state.patrol


func handle_patrol():
	#$AnimatedSprite2D.flip_h = false = facing left
	if $AnimatedSprite2D.flip_h:
		velocity.x = speed 
		$PatrolRay.target_position = Vector2(10.0, 0)
		$PatrolRay2.position = Vector2(10.0,0)
		$PatrolRay2.target_position = Vector2(0, 15.0)
	else:
		velocity.x = -speed 
		$PatrolRay.target_position = Vector2(-10.0, 0)
		$PatrolRay2.position = Vector2(-10.0,0)
		$PatrolRay2.target_position = Vector2(0, 15.0)
		
	if $PatrolRay.is_colliding():
		$AnimatedSprite2D.flip_h = !$AnimatedSprite2D.flip_h  # Toggle horizontal flip
		velocity.x *= -1  # Reverse movement direction
	if !$PatrolRay2.is_colliding():
		$AnimatedSprite2D.flip_h = !$AnimatedSprite2D.flip_h  # Toggle horizontal flip
		velocity.x *= -1  # Reverse movement direction

func die():
	queue_free()
