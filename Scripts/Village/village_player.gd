class_name VillageCharacter extends Node2D

@export var ground: TileMapLayer
@export var triggers: TriggersLayer
@export_range(0.01, 1.0) var step_duration: float = 0.18

@onready var camera: Camera2D = $Camera2D
@export var PlayerVisual : CharVisual

var cell: Vector2i
var cached_position: Vector2
var vel: Vector2
var moving: bool = false

func get_tile_maps() -> void:
	var found_ground := get_node("../Ground")
	if is_instance_valid(found_ground):
		ground = found_ground
	var found_triggers := ground.get_node("../TriggersLayer")
	if is_instance_valid(found_triggers):
		triggers = found_triggers

func _ready() -> void:
	get_tile_maps()
	# 将角色吸附到所在格子的中心。
	cell = ground.local_to_map(ground.to_local(global_position))
	global_position = cell_to_world(cell)
	cached_position = global_position

	setup_camera()


func setup_camera() -> void:
	# 相机作为角色的子节点，自动跟随角色。
	camera.position = Vector2.ZERO
	camera.offset = Vector2.ZERO
	camera.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER

	# 角色本身已经使用 Tween 平滑移动。
	# 关闭额外的相机平滑，避免跟随滞后导致角色偏离中心。
	camera.position_smoothing_enabled = false
	camera.drag_horizontal_enabled = false
	camera.drag_vertical_enabled = false

	update_camera_limits()

	camera.enabled = true
	camera.make_current()
	camera.force_update_scroll()


func update_camera_limits() -> void:
	# 所有已绘制格子的外接矩形，单位为格子。
	var used_rect: Rect2i = ground.get_used_rect()

	if used_rect.size == Vector2i.ZERO:
		return

	var half_tile := Vector2(ground.tile_set.tile_size) * 0.5

	# map_to_local 返回格子中心；
	# 加减半格后得到地图的外边缘。
	var local_min := ground.map_to_local(used_rect.position) - half_tile
	var last_cell := used_rect.end - Vector2i.ONE
	var local_max := ground.map_to_local(last_cell) + half_tile

	# Camera2D 的边界使用世界坐标。
	var world_min := ground.to_global(local_min)
	var world_max := ground.to_global(local_max)

	camera.limit_left = floori(minf(world_min.x, world_max.x))
	camera.limit_top = floori(minf(world_min.y, world_max.y))
	camera.limit_right = ceili(maxf(world_min.x, world_max.x))
	camera.limit_bottom = ceili(maxf(world_min.y, world_max.y))


func _process(delta: float) -> void:
	vel = (global_position - cached_position) / delta
	cached_position = global_position
	if is_instance_valid(PlayerVisual):
		PlayerVisual.set_move_amount(vel.length())
	if moving:
		return

	var direction := Vector2i.ZERO

	if Input.is_action_pressed("Right"):
		direction = Vector2i.RIGHT
		if is_instance_valid(PlayerVisual):
			PlayerVisual.moving_right = true
	elif Input.is_action_pressed("Left"):
		direction = Vector2i.LEFT
		if is_instance_valid(PlayerVisual):
			PlayerVisual.moving_right = false
	elif Input.is_action_pressed("Down"):
		direction = Vector2i.DOWN
	elif Input.is_action_pressed("Up"):
		direction = Vector2i.UP

	if direction != Vector2i.ZERO:
		try_move(direction)


func try_move(direction: Vector2i) -> void:
	var next_cell := cell + direction

	if not can_walk(next_cell):
		return

	moving = true

	var target := cell_to_world(next_cell)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "global_position", target, step_duration)

	await tween.finished
	
	global_position = target
	cell = next_cell
	if is_instance_valid(triggers):
		for trigger in triggers.triggers:
			if trigger.location == cell:
				if is_instance_valid(trigger.script_def):
					var new_script_object : Object = trigger.script_def.new()
					new_script_object.call("trigger", get_tree())
					new_script_object.free()
	moving = false

func can_walk(target_cell: Vector2i) -> bool:
	var tile_data := ground.get_cell_tile_data(target_cell)

	if tile_data == null:
		return false

	return bool(tile_data.get_custom_data("walkable"))


func cell_to_world(target_cell: Vector2i) -> Vector2:
	return ground.to_global(ground.map_to_local(target_cell))
