extends enemies

class_name targeting_enemies

@export var vision_range : int = 50
enum enemy_state {
	idle,
	roam,
	approach,
	attack
}

var current_state = enemy_state.idle
var direction = 1 
var range_to_player:float
var player:Node2D = null
var timer: Timer
var wait_time:float = randomize_wait_time()
var roam_time = 2
@export var attack_range:float

func _ready() -> void:
	$VisionRange.connect("body_entered", _on_player_detected)
	$VisionRange.connect("body_exited", _on_player_lost)
	$VisionRange/CollisionShape2D.shape.radius = vision_range
	timer = Timer.new()
	timer.wait_time = wait_time  # Random time between 2-5s
	timer.one_shot = true  # Keep repeating
	timer.autostart = false  # Start automatically
	add_child(timer)  # Add to the node tree
	timer.timeout.connect(_on_timer_timeout)


func _physics_process(delta: float) -> void:

	if !is_on_floor():
		velocity.y += gravity * delta
	if direction == 1:
		$Sprite2D.flip_h = true
	elif direction == -1:
		$Sprite2D.flip_h = false

	move_and_slide()
	
	match current_state:
		enemy_state.idle:
			handle_idle()
		enemy_state.roam:
			handle_roam()
		enemy_state.approach:
			handle_approach()
		enemy_state.attack:
			handle_attack()
func handle_idle():
	velocity.x = 0
	if timer.is_stopped():
		wait_timer_start()

func handle_roam():
	if timer.is_stopped():
		roam_timer_start()
	if direction == 1:
		velocity.x = direction * speed
	elif direction == -1:
		velocity.x = direction * speed

func handle_approach():
	if player:
		direction = sign(player.global_position.x - global_position.x)
		range_to_player = abs(player.global_position.x - global_position.x)
		print(range_to_player)
		velocity.x = direction * speed
		if range_to_player <= attack_range:
			current_state = enemy_state.attack

func handle_attack():
	print("attacking!!!!")

func _on_player_detected(body: Node2D):
	player = body
	current_state = enemy_state.approach

func randomize_wait_time():
	var wait_time = randi_range(3, 6)
	return wait_time
	
func _on_player_lost(body: Node2D):
	current_state = enemy_state.idle

func _on_timer_timeout():
	if current_state == enemy_state.idle:
		current_state = enemy_state.roam
	elif current_state == enemy_state.roam:
		current_state = enemy_state.idle

func roam_timer_start():
	direction *= -1
	timer.wait_time = roam_time
	timer.start()

func wait_timer_start():
	timer.wait_time = wait_time
	timer.start()
