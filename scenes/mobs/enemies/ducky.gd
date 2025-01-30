extends patrol_enemies


func _ready() -> void:
	super()
	print("hi im ducky")

func _physics_process(delta: float) -> void:
	super(delta)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	take_damage(area.get_parent().stats["damage"])
	print("damage taken: ", area.get_parent().stats["damage"])
