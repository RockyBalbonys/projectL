extends CharacterBody2D
class_name enemies

@export var hp : int 
@export var damage : int
@export var speed : int
@export var gravity : int


func _ready() -> void:
	pass
	
func take_damage(amount):
	hp = hp - amount
	if hp <= 0:
		die()
	print("hp left: ", hp)

func inflict_damage(target):
	if target.has_method("take_damage"):
		target.take_damage(damage)
	

func die():
	queue_free()
