extends enemies

class_name bosses

enum boss_state {
	waiting,
	approach,
	attack,
	retreat
}

var current_state = boss_state.waiting
var direction = -1
var player: CharacterBody2D
var range_to_player: float
@export var vision_range: float

func _ready() -> void:
	$VisionRange.connect("body_entered", _on_player_detected)
	$VisionRange.connect("body_exited", _on_player_exited)
	$VisionRange/CollisionShape2D.shape.radius = vision_range

func _physics_process(delta: float) -> void:
	#
	#print("direction: ", direction)
	#print("range_to_player: ", range_to_player)
	if !is_on_floor():
		velocity.y += gravity * delta
	if direction == 1:
		$AnimatedSprite2D.flip_h = true
	elif direction == -1:
		$AnimatedSprite2D.flip_h = false
	move_and_slide()
	
	match current_state:
		boss_state.waiting:
			handle_waiting()
		boss_state.approach:
			handle_approach()
		boss_state.attack:
			handle_attack()
		boss_state.retreat:
			handle_retreat()


func handle_waiting():
	velocity.x = 0
	
func handle_approach():
	if player:
		direction = sign(player.global_position.x - global_position.x)
		range_to_player = abs(player.global_position.x - global_position.x)
		velocity.x = direction * speed
		#$AnimatedSprite2D.play("walking")
		if range_to_player <= 30:
			velocity.x = 0
		if range_to_player <= 100:
			current_state = boss_state.attack
		else:
			current_state = boss_state.approach
	else:
		current_state = boss_state.waiting
		

func handle_attack():
	pass

func handle_retreat():
	pass
	
func _on_player_detected(body: Node2D):
	print("player detected: ", body)
	player = body
	current_state = boss_state.approach

func _on_player_exited(body: Node2D):
	player = null
