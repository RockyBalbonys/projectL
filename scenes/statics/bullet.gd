extends StaticBody2D
var speed = 300  # Adjust this for how fast the bullet moves
var direction = Vector2(1, 0)  # Default direction: right
var damage: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(3).timeout
	queue_free()  # Destroy the bullet after 3 seconds


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	position += direction * speed * delta
