class_name RoundTime extends Node

@onready var asc : AbilitySystemComponent = $AbilitySystemComponent
var round_set : RoundAttributeSet
var is_round_start : bool = false
var pause : bool = false

var route_run : BranchRouteRun_AH = null
@export var route_map_scene : PackedScene
var route_map_instance : BranchRouteMapRoot

@export var player : MainPlayer

@export var round_end_store_prefab : PackedScene

var round_end_store : RoundEndStore

signal round_start()
signal round_end()

signal on_goal_reach()

func _init() -> void:
	add_to_group("Persist")

func destroy_route_run() -> void:
	if is_instance_valid(route_run):
		route_run.queue_free()
		route_run = null

func new_route_run() -> BranchRouteRun_AH:
	if not is_instance_valid(route_run):
		route_run = BranchRouteRun_AH.new()
	return route_run
	
func save_game() -> Dictionary:
	if is_instance_valid(route_run):
		return {"route_run" : route_run.save_game()}
	return {}
	
func load_game(in_data : Dictionary) -> void:
	if in_data.has("route_run"):
		destroy_route_run()
		new_route_run().load_game(in_data["route_run"])
	
func get_player() -> MainPlayer:
	if not player:
		var current_scene_root := get_tree().current_scene
		player = current_scene_root.get_node("Player")
	return player

func _on_continue_pressed() -> void:
	round_end_store.queue_free()
	round_end_store = null
	route_node_complete()
	## var rset := find_round_time_set()
	## if is_instance_valid(rset):
		## rset.current_day._set_base_value(rset.current_day.current_value + 1)
	## start_round()

func create_round_end_store() -> void:
	if round_end_store_prefab.can_instantiate():
		round_end_store = round_end_store_prefab.instantiate()
		if is_instance_valid(round_end_store):
			round_end_store.asc_owner = get_player()
			round_end_store.continue_button.pressed.connect(_on_continue_pressed)
			var current_scene_root := get_tree().current_scene
			current_scene_root.add_child(round_end_store)

func start_round() -> void:
	is_round_start = true;
	var rset := find_round_time_set()
	if is_instance_valid(rset):
		rset.current_round_time._set_base_value(rset.round_time.current_value)
	round_start.emit()

func end_round() -> void:
	is_round_start = false
	round_end.emit()
	
func pause_round() -> void:
	round_end.emit()
	pause = true

func unpause_round() -> void:
	pause = false
	round_start.emit()

func set_target_distance(target_distance : int) -> void:
	var rset := find_round_time_set()
	if is_instance_valid(rset):
		rset.target_distance._set_base_value(target_distance)

func route_node_complete() -> void:
	pause_round()
	route_run.complete_encounter(route_run.pending_id)
	SaveGameManager.save_game()
	create_route_map_widget()
		
func reach_goal() -> void:
	clear_distance()
	route_node_complete()
	on_goal_reach.emit()
		
func clear_distance() -> void:
	var rset := find_round_time_set()
	if is_instance_valid(rset):
		rset.current_distance._set_base_value(0)
		
func add_distance() -> void:
	var rset := find_round_time_set()
	if is_instance_valid(rset):
		rset.current_distance._set_base_value(rset.current_distance.current_value + 1)
		if rset.current_distance.current_value >= rset.target_distance.current_value:
			reach_goal()

func find_round_time_set() -> RoundAttributeSet:
	if is_instance_valid(round_set):
		return round_set
	if is_instance_valid(asc):
		for aset in asc.attribute_sets:
			var rset : RoundAttributeSet = aset
			if is_instance_valid(rset):
				round_set = rset
	return round_set

func update_round_time(delta: float) -> void:
	if !is_round_start or pause:
		return
	var rset := find_round_time_set()
	if is_instance_valid(rset):
		rset.current_round_time._set_base_value(rset.current_round_time.base_value - delta)
	var current_time := asc.get_attribute("current_round_time").current_value
	if current_time <= 0:
		end_round()

func _encounter_requested(node_id: int, kind: String) -> void:
	if kind == "battle":
		set_target_distance(route_run.nodes[node_id]["enemy_count"])
		if is_round_start:
			if pause:
				unpause_round()
		else:
			print("start round")
			start_round()
	elif kind == "shop":
		create_round_end_store()
	if is_instance_valid(route_map_instance):
		route_map_instance.queue_free()
		route_map_instance = null

func create_route_map_widget() -> void:
	if is_round_start:
		pause_round()
	if not is_instance_valid(route_map_instance) and route_map_scene.can_instantiate():
		route_map_instance = route_map_scene.instantiate() as BranchRouteMapRoot
		if is_instance_valid(route_map_instance.branch_route_map):
			route_map_instance.branch_route_map.bind(route_run)
			get_tree().current_scene.add_child.call_deferred(route_map_instance)

func _ready() -> void:
	GlobalVars.round_time = self
	if SaveGameManager.current_save_data.has(get_script().get_global_name()):
		load_game(SaveGameManager.current_save_data[get_script().get_global_name()])
	else:
		new_route_run().new_run()
	route_run.encounter_requested.connect(_encounter_requested)
	if route_run.pending_id < 0:
		create_route_map_widget()
	else:
		_encounter_requested(route_run.pending_id, route_run.nodes[route_run.pending_id]["kind"])
	## start_round()

func _exit_tree() -> void:
	GlobalVars.round_time = null

func _process(delta: float) -> void:
	update_round_time(delta)
