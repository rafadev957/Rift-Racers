extends Node

class_name Track # definindo o nome de classe para Track






func _on_track_collision_area_entered(area: Area2D) -> void:
	if area is Car: area.hit_boundary()
