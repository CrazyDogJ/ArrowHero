@tool
class_name TriggersLayer extends Node2D

@export var tile_map : TileMapLayer
@export var triggers : Array[TriggerInfo]

func _ready() -> void:
	var found_tile_map := get_parent().get_node("Ground")
	if is_instance_valid(found_tile_map):
		tile_map = found_tile_map

func _draw() -> void:
	if not is_instance_valid(tile_map):
		return
	for trigger in triggers:
		var location := tile_map.map_to_local(trigger.location)
		var script := trigger.script_def
		var string : String = script.resource_path.get_file() if is_instance_valid(script) else "No Script"
		var tile_size := tile_map.to_local(Vector2(tile_map.tile_set.tile_size) * tile_map.scale)
		draw_string(ThemeDB.fallback_font, location - tile_size * 0.5, string, HORIZONTAL_ALIGNMENT_CENTER, -1, 8)
		var rect_color : Color = Color.WHITE
		rect_color.a = 0.5
		draw_rect(Rect2(location - tile_size * 0.5, tile_size), rect_color, false, 2)

func _process(delta: float) -> void:
	pass
