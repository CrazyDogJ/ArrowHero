class_name RoundTime extends Node

@onready var asc : AbilitySystemComponent = $AbilitySystemComponent
var round_set : RoundAttributeSet
var is_round_start : bool = false

@export var player : MainPlayer

@export var round_end_store_prefab : PackedScene

var round_end_store : RoundEndStore

signal round_start()
signal round_end()

func get_player() -> MainPlayer:
	if not player:
		player = get_tree().root.get_node("Player")
	return player

func _on_continue_pressed() -> void:
	round_end_store.queue_free()
	round_end_store = null
	start_round()

func create_round_end_store() -> void:
	if round_end_store_prefab.can_instantiate():
		round_end_store = round_end_store_prefab.instantiate()
		if is_instance_valid(round_end_store):
			round_end_store.asc_owner = get_player()
			round_end_store.continue_button.pressed.connect(_on_continue_pressed)
			get_tree().root.add_child(round_end_store)

func start_round() -> void:
	is_round_start = true;
	var rset := find_round_time_set()
	if is_instance_valid(rset):
		rset.current_round_time._set_base_value(rset.round_time.current_value)
	round_start.emit()

func end_round() -> void:
	is_round_start = false
	round_end.emit()
	create_round_end_store()
		
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
	if !is_round_start:
		return
	var rset := find_round_time_set()
	if is_instance_valid(rset):
		rset.current_round_time._set_base_value(rset.current_round_time.base_value - delta)
	var current_time := asc.get_attribute("current_round_time").current_value
	if current_time <= 0:
		end_round()
	
func _ready() -> void:
	start_round()

func _process(delta: float) -> void:
	update_round_time(delta)
