class_name BranchRouteRun
extends Node
## 纯玩法状态，不依赖地图 UI。可放入 Autoload，跨场景保留进度。

signal changed
signal encounter_requested(node_id: int, kind: String)
signal route_finished

@export_range(2, 20) var branch_layers: int = 7
@export_range(2, 6) var max_width: int = 3

@export var default_type: String = "battle"
@export var finish_type: String = "boss"
## Pool 改成使用权重形式的Dictionary
## "event" : 1.0, "rest" : 1.0
@export var encounter_pool: Dictionary[String, float] = {"battle" : 2.0, "shop" : 1.0}

var nodes: Array[Dictionary] = []
var rows: Array = []
var current_id: int = 0
var pending_id: int = -1
var visited: Array[int] = []
var finished: bool = false
var run_seed: int = 0

func save_game() -> Dictionary:
	var save_dict = {
		"nodes" : nodes,
		"rows" : rows,
		"current_id" : current_id,
		"pending_id" : pending_id,
		"visited" : visited,
		"finished" : finished,
		"run_seed" : run_seed
	}
	return save_dict

func load_game(in_data : Dictionary) -> void:
	nodes.assign(in_data.get("nodes"))
	rows = in_data.get("rows")
	current_id = in_data.get("current_id")
	pending_id = in_data.get("pending_id")
	visited.assign(in_data.get("visited"))
	finished = in_data.get("finished")
	run_seed = in_data.get("run_seed")

# You can override the rng var in this function
func _get_rng() -> RandomNumberGenerator:
	return RandomNumberGenerator.new()

func new_run() -> void:
	var rng := _get_rng()
	run_seed = rng.seed
	print(run_seed)
	nodes.clear()
	rows.clear()
	visited.clear()
	current_id = 0
	pending_id = -1
	finished = false
	_add_row(1, "start", rng)
	for layer in range(clampi(branch_layers, 2, 20)):
		_add_row(rng.randi_range(2, clampi(max_width, 2, 6)), "", rng)
	_add_row(1, finish_type, rng)
	# 按左右顺序连接相邻行；只向右移动游标，因此不会产生交叉线。
	# 每个节点都有入边和出边（起点/终点 除外），不会生成孤点或死路。
	for row_index in range(rows.size() - 1):
		var lower: Array = rows[row_index]
		var upper: Array = rows[row_index + 1]
		var a: int = 0
		var b: int = 0
		_link(lower[a], upper[b])
		while a < lower.size() - 1 or b < upper.size() - 1:
			if a == lower.size() - 1:
				b += 1
			elif b == upper.size() - 1:
				a += 1
			else:
				var step: int = rng.randi_range(0, 2)
				if step != 1:
					a += 1
				if step != 0:
					b += 1
			_link(lower[a], upper[b])
	visited.append(current_id)
	changed.emit()

func _add_row(count: int, fixed_kind: String, rng: RandomNumberGenerator) -> void:
	var row: Array[int] = []
	for column in range(count):
		var kind: String = fixed_kind
		if kind.is_empty():
			if encounter_pool.is_empty():
				kind = default_type
			else:
				kind = encounter_pool.keys()[rng.rand_weighted(encounter_pool.values())]
		var id: int = nodes.size()
		nodes.append({"id": id, "row": rows.size(), "column": column,
			"kind": kind, "next": []})
		_post_node_append(id)
		row.append(id)
	rows.append(row)

func _post_node_append(node_id: int) -> void:
	pass

func _link(from_id: int, to_id: int) -> void:
	nodes[from_id]["next"].append(to_id)

func available_ids() -> Array[int]:
	var result: Array[int] = []
	if nodes.is_empty() or finished or pending_id != -1:
		return result
	for id in nodes[current_id]["next"]:
		result.append(int(id))
	return result

func choose(node_id: int) -> bool:
	if not available_ids().has(node_id):
		return false
	pending_id = node_id
	changed.emit()
	encounter_requested.emit(node_id, String(nodes[node_id]["kind"]))
	return true

## 必须传回本次事件 ID，防止重复/过期回调推进路线。
## success=false 保留当前待处理事件，不允许失败后改选其他分支。
## 游戏失败时由你的游戏流程调用 new_run() 或返回标题界面。
func complete_encounter(node_id: int, success: bool = true) -> bool:
	if node_id != pending_id or pending_id == -1 or not success:
		return false
	current_id = pending_id
	pending_id = -1
	visited.append(current_id)
	finished = String(nodes[current_id]["kind"]) == finish_type
	changed.emit()
	if finished:
		route_finished.emit()
	return true
