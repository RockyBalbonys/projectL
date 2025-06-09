extends patrol_enemies


func _on_hurtbox_area_entered(area: Area2D) -> void:
	take_damage(area.get_parent().stats["damage"])
	print("damage taken: ", area.get_parent().stats["damage"])
