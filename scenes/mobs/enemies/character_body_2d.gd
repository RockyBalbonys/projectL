extends CharacterBody2D

var speed = 200  # Movement speed
var damage = 20  # Damage dealt to the player
var health = 50  # Enemy health
# branch recodePlayer
# PATROL VARIABLES
@export var patrol_range: float = 300  # Total distance the enemy patrols
@export var start_position: Vector2  # Initial position of the enemy
var direction = 1  # Current movement direction (1 = right, -1 = left)

func _ready() -> void:
	# Store the initial position to calculate patrol range
	start_position = position

func _physics_process(delta: float) -> void:
	patrol(delta)

func patrol(delta: float):
	# Move the enemy
	velocity.x = speed * direction
	move_and_slide()

	# Check if the enemy is at the edge of the patrol range
	var distance_from_start = abs(position.x - start_position.x)
	if distance_from_start >= patrol_range:
		# Reverse direction when reaching the patrol limit
		direction *= -1
