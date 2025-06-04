extends TileMapLayer


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var mouse_pos := get_local_mouse_position()
	
	var aligned_pos := Vector2(map_to_local(local_to_map(mouse_pos)))
	draw_circle(aligned_pos, 5, Color.RED)
