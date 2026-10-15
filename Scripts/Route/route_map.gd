class_name BranchRouteMap
extends Control
## 放进 ScrollContainer；按钮负责鼠标/触摸/键盘，_draw 只绘制路线。

@export_category("Layout")
@export var row_spacing: float = 105.0
@export var column_spacing: float = 140.0
@export var node_size := Vector2(92, 56)

@export_category("Color")
@export var disable_color := Color("6b7180")
@export var visited_color := Color("7cc4ac")
@export var available_color := Color("ffd680")
@export var current_color := Color("ffffff")

var run: BranchRouteRun
var _centers: Dictionary = {}
var _buttons: Dictionary = {}
var _labels: Dictionary = {
	"start": "START", "battle": "BATTLE", "event": "EVENT",
	"rest": "REST", "shop": "SHOP", "boss": "BOSS"
}

func scroll_to_current() -> void:
	# _rebuild() 刚创建了按钮，要等下一帧完成容器布局。
	await get_tree().process_frame

	if not is_inside_tree() or not is_instance_valid(run):
		return

	# 原工程中 RouteMap 的父节点就是 ScrollContainer。
	var scroll := get_parent() as ScrollContainer
	if scroll == null:
		return

	# 正在处理事件时定位到选中的节点，否则定位到已到达节点。
	var target_id: int = run.current_id
	if run.pending_id != -1:
		target_id = run.pending_id

	var button := _buttons.get(target_id) as Control
	if is_instance_valid(button):
		scroll.ensure_control_visible(button)
		button.grab_focus.call_deferred()

func _ready() -> void:
	resized.connect(_layout)
	scroll_to_current()

func bind(value: BranchRouteRun) -> void:
	if is_instance_valid(run) and run.changed.is_connected(_rebuild):
		run.changed.disconnect(_rebuild)
	run = value
	if is_instance_valid(run):
		run.changed.connect(_rebuild)
	_rebuild()

func set_kind_labels(labels: Dictionary) -> void:
	_labels.merge(labels, true)
	_rebuild()

func _rebuild() -> void:
	for button in _buttons.values():
		remove_child(button)
		button.queue_free()
	_buttons.clear()
	_centers.clear()
	if not is_instance_valid(run):
		queue_redraw()
		return
	var available: Array[int] = run.available_ids()
	var widest: int = 1
	for row in run.rows:
		widest = maxi(widest, row.size())
	custom_minimum_size = Vector2((widest - 1) * column_spacing + 160,
		maxi(1, run.rows.size() - 1) * row_spacing + 140)
	for data in run.nodes:
		var id: int = int(data["id"])
		var button := Button.new()
		button.text = String(_labels.get(data["kind"], data["kind"]))
		button.tooltip_text = "Node %d | %s" % [id, data["kind"]]
		button.custom_minimum_size = node_size
		button.size = node_size
		button.disabled = not available.has(id)
		var color := disable_color
		if run.visited.has(id):
			color = visited_color
		if available.has(id):
			color = available_color
		if id == run.current_id or id == run.pending_id:
			color = current_color
			button.text = "> " + button.text
		button.add_theme_color_override("font_color", color)
		button.add_theme_color_override("font_disabled_color", color)
		button.pressed.connect(_choose.bind(id))
		add_child(button)
		_buttons[id] = button
	_layout()

func _choose(id: int) -> void:
	if is_instance_valid(run):
		run.choose(id)

func _layout() -> void:
	if not is_instance_valid(run):
		return
	for data in run.nodes:
		var id: int = int(data["id"])
		if not _buttons.has(id):
			continue
		var row: int = int(data["row"])
		var count: int = run.rows[row].size()
		var center := Vector2(maxf(size.x, custom_minimum_size.x) * 0.5
			+ (float(data["column"]) - float(count - 1) / 2.0) * column_spacing,
			70.0 + (run.rows.size() - 1 - row) * row_spacing)
		_centers[id] = center
		_buttons[id].position = center - _buttons[id].size / 2.0
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(run):
		return
	var available: Array[int] = run.available_ids()
	for data in run.nodes:
		var from_id: int = int(data["id"])
		if not _centers.has(from_id):
			continue
		for to_id_float in data["next"]:
			var to_id : int = int(to_id_float)
			if not _centers.has(to_id):
				continue
			var color := disable_color
			var width: float = 2.0
			var used: bool = false
			var path_index: int = run.visited.find(from_id)
			if path_index >= 0 and path_index + 1 < run.visited.size():
				used = run.visited[path_index + 1] == to_id
			if used:
				color = visited_color
				width = 4.0
			elif from_id == run.current_id and (available.has(to_id) or to_id == run.pending_id):
				color = available_color
				width = 4.0
			draw_line(_centers[from_id], _centers[to_id], color, width, true)
