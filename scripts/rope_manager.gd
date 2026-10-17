extends Node2D

var rope_parts := []
var piece_length = 4.0

func spawn_rope(start_pos: Vector2, end_pos: Vector2):
	var distance = start_pos.distance_to(end_pos)
	var segment_amount = distance / piece_length
	
	
	pass
