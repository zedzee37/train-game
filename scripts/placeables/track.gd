class_name Track
extends Node2D


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if not GameTileMap.instance:
		return
	
	for dir: Vector2 in Utils.cardinals:
		var neighbor_pos := GameTileMap.instance.local_to_map(global_position) + Vector2i(dir)

		var neighbor = GameTileMap.instance.get_placed(neighbor_pos)

		if neighbor is Track:
			print_debug("has neighbor")

		draw_circle(Vector2(0, 0), 16, Color.WHITE)

