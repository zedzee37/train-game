class_name GameTileMap
extends TileMapLayer


signal placed(node: Node2D)


@onready var preview_sprite: Sprite2D = $PreviewSprite


@export var placeables: Array[PackedScene]
@export var _preview_period: float = 1.0
@export var _preview_base_alpha: float = 0.05
@export var _preview_amplitude: float = 0.17


static var instance: GameTileMap


var _selected_placeable_idx: int = 0
var _selected_placeable: Node2D
var _preview_time: float = 0.0
var _preview_frequency: float
var _placed: Dictionary[Vector2i, Node2D] = {}


func _ready() -> void:
    instance = self
    _preview_frequency = (2 * PI) / _preview_period


func _process(_delta: float) -> void:
    var aligned_pos := to_aligned(get_local_mouse_position())
    preview_sprite.position = aligned_pos

    if _selected_placeable == null:
        _create_temp_instance()

    if Input.is_action_pressed("place"):
        place(_selected_placeable, get_local_mouse_position())

    _preview_time += _delta

    if _preview_time >= _preview_period:
        _preview_time = 0

    var oscillation := (sin(
            _preview_time * _preview_frequency) + 1.0
        ) / 2.0 * _preview_amplitude

    preview_sprite.modulate.a = (
            _preview_base_alpha + oscillation * (1.0 - _preview_base_alpha)
        )


func to_aligned(pos: Vector2) -> Vector2:
    var map_pos := local_to_map(pos)
    return map_to_local(map_pos) - Vector2(tile_set.tile_size / 2)


func get_unaligned(pos: Vector2) -> Node2D:
    var aligned_pos := map_to_local(local_to_map(pos))	
    return get_placed(aligned_pos)


func get_placed(pos: Vector2i) -> Node2D:
    if not _placed.has(pos):
        return null
    return _placed[pos]


func place(placeable: Node2D, pos: Vector2) -> void:
    if _placed.has(local_to_map(pos)):
        return

    var aligned_pos := to_aligned(pos)
    add_child(placeable)
    placeable.global_position = aligned_pos
    _placed[local_to_map(pos)] = placeable

    if placeable == _selected_placeable:
        _create_temp_instance()


func _create_temp_instance() -> void:
    var selected_scene := placeables[_selected_placeable_idx]

    _selected_placeable = selected_scene.instantiate()	

    if _selected_placeable.has_node("Sprite2D"):
        var sprite: Sprite2D = _selected_placeable.get_node("Sprite2D")
        preview_sprite.texture = sprite.texture
    else:
        preview_sprite.texture = null
        push_warning(
        "\"Sprite2D\" Node not found in target placeable, scene path: "
        + selected_scene.resource_path + "."
        )
