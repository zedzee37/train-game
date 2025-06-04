class_name GameTileMap
extends TileMapLayer


signal placed(node: Node2D)


@onready var preview_sprite: Sprite2D = $PreviewSprite


@export var placeables: Array[PackedScene]
@export var _preview_period: float = 1.0
@export var _preview_base_alpha: float = 0.05
@export var _preview_amplitude: float = 0.17


var _selected_placeable_idx: int = 0
var _selected_placeable: Node2D
var _preview_time: float = 0.0
var _preview_frequency: float


func _ready() -> void:
	_preview_frequency = (2 * PI) / _preview_period


func _process(_delta: float) -> void:
	var mouse_pos := get_local_mouse_position()
	var aligned_pos := map_to_local(local_to_map(mouse_pos))
	preview_sprite.position = aligned_pos

	if _selected_placeable == null:
		_create_temp_instance()

	if Input.is_action_just_pressed("place"):
		_selected_placeable.global_position = to_global(aligned_pos)
		get_parent().add_child(_selected_placeable)
		_create_temp_instance()

	_preview_time += _delta
	
	if _preview_time >= _preview_period:
		_preview_time = 0
	
	var oscillation := (sin(
		_preview_time * _preview_frequency) + 1.0
	) / 2.0 * _preview_amplitude

	preview_sprite.modulate.a = (
		_preview_base_alpha + oscillation * (1.0 - _preview_base_alpha)
	)
	
func _create_temp_instance() -> void:
	var selected_scene := placeables[_selected_placeable_idx]

	_selected_placeable = selected_scene.instantiate()	
	
	if _selected_placeable.has_node("Sprite2D"):
		var sprite: Sprite2D = _selected_placeable.get_node("Sprite2D")
		preview_sprite.texture = sprite.texture
	else:
		preview_sprite.texture = null
		push_error(
			"\"Sprite2D\" Node not found in target placeable, scene path: "
			+ selected_scene.resource_path + "."
		)


