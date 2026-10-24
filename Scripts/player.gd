extends Node

class_name MainPlayer

const ah_inputs = preload("res://Scripts/ah_input.gd")
const enums = preload("res://Scripts/enums.gd")

const tags = preload("res://godot_gas/gameplay_tags.gd")
const ga_arrow_input = preload("res://godot_gas/abilities/ga_arrow_input.gd")
const ga_spawn_arrow_board = preload("res://godot_gas/abilities/ga_spawn_arrow_board.gd")

@export var loc_node : CanvasItem
@export var enemy_manager : EnemyManager

@onready var asc : AbilitySystemComponent = $AbilitySystemComponent
@onready var card_manager : UpgradeCardsManager = $UpgradeCardsManager

@export var dead_widget_scene : PackedScene

@export_category("Ability System")
@export var abilities : Array[PackedScene]
@export var effects : Array[GameplayEffect]
@export var wrong_damage_effect : GameplayEffect
@export var finish_effect : GameplayEffect
@export var attack_effect : GameplayEffect

@export_category("Damage Number")
@export var damage_number_spawn_node : Node2D
@export var self_damage_number_spawn_node : Node2D

var current_attack_board : ArrowBoard
var is_round_start : bool = false

const uccp := preload("res://godot_gas/upgrade_cards/upgrade_card_calculation.gd")

func save_attribute_sets() -> Dictionary[String,Dictionary]:
	var aset_save_dictionary : Dictionary[String,Dictionary]
	for aset in asc.attribute_sets:
		var aset_save : Dictionary[String,float]
		for property in aset.get_property_list():
			if property["class_name"] == StringName("AttributeData"):
				var property_name : String = property.name
				var property_current_value : float = aset.get(property_name).current_value
				aset_save.get_or_add(property_name, property_current_value)
		aset_save_dictionary.get_or_add(aset.get_script().get_global_name(), aset_save)
	return aset_save_dictionary
	
func load_attribute_sets(in_data : Dictionary) -> void:
	var attribute_sets_data : Dictionary[String,Dictionary]
	attribute_sets_data.assign(in_data)
	for aset in asc.attribute_sets:
		var found_aset_data : Dictionary[String,float]
		found_aset_data.assign(attribute_sets_data.get(aset.get_script().get_global_name()))
		for attribute_name in found_aset_data.keys():
			var attr : AttributeData = aset.get(attribute_name)
			attr.current_value = found_aset_data[attribute_name]
	
func save_game() -> Dictionary:
	var save_data : Dictionary
	if is_instance_valid(card_manager):
		var card_manager_datas := card_manager.save_game()
		save_data.get_or_add("card_manager_datas", card_manager_datas)
	if is_instance_valid(asc):
		var attribute_set_datas := save_attribute_sets()
		save_data.get_or_add("attribute_set_datas", attribute_set_datas)
	return save_data
	
func load_game(in_data : Dictionary) -> void:
	if is_instance_valid(card_manager):
		card_manager.load_game(in_data.get("card_manager_datas"))
	if is_instance_valid(asc):
		load_attribute_sets(in_data.get("attribute_set_datas"))

func spawn_board() -> void:
	if is_round_start:
		var payload : ga_spawn_arrow_board.SpawnArrowBoardPayload = ga_spawn_arrow_board.SpawnArrowBoardPayload.new(self, loc_node, tags.Arrowboard_Normal)
		asc.send_gameplay_event(tags.Ability_Spawnarrowboard_Input, payload)

func destroy_board() -> void:
	if is_instance_valid(current_attack_board):
		current_attack_board.queue_free()
	current_attack_board = null

func process_input(event: InputEvent) -> void:
	if is_instance_valid(current_attack_board):
		current_attack_board.Logic._input(event)

func handle_cards_arrow_input(in_payload : uccp.ArrowInputPayload) -> void:
	if is_instance_valid(card_manager):
		for active_card in card_manager.active_cards:
			var card : UpgradeCard = active_card.get_effect_def()
			if is_instance_valid(card):
				in_payload.Card = card
				card.handle_arrow_input(in_payload, asc, enemy_manager.current_enemy.get_ability_component())

func handle_cards_board_finish(in_payload : uccp.ArrowBoardFinishPayload) -> void:
	if is_instance_valid(card_manager):
		for active_card in card_manager.active_cards:
			var card : UpgradeCard = active_card.get_effect_def()
			if is_instance_valid(card):
				in_payload.Card = card
				card.handle_arrow_finish(in_payload, asc, enemy_manager.current_enemy.get_ability_component())

func _attack_board_press(Index : int, ArrowDirection : enums.ArrowDirection, ArrowResult : enums.ArrowState) -> void:
	if ArrowResult == enums.ArrowState.Wrong:
		asc.apply_gameplay_effect(wrong_damage_effect)
	handle_cards_arrow_input(uccp.ArrowInputPayload.new(null, Index, ArrowDirection, ArrowResult))

func _attack_board_finish(ArrowDirections : Array[enums.ArrowDirection], ArrowResults : Array[enums.ArrowState], TimeRemain : float) -> void:
	if !is_round_start:
		return
	current_attack_board = null
	asc.apply_gameplay_effect(finish_effect)
	if is_instance_valid(enemy_manager) and is_instance_valid(enemy_manager.current_enemy) and is_instance_valid(enemy_manager.current_enemy.get_ability_component()):
		var base_damage : float = asc.get_attribute("base_damage").current_value
		var correct_num : int = enums.get_correct_num(ArrowResults)
		var damage : float = correct_num * base_damage
		var instigator = asc.get_parent() if asc else get_parent()
		var context = GameplayEffectContext.new(instigator)
		var spec = GameplayEffectSpec.new(attack_effect, context, damage)
		asc.apply_effect_spec_to_target(spec, enemy_manager.current_enemy.get_ability_component())
	handle_cards_board_finish(uccp.ArrowBoardFinishPayload.new(null, ArrowDirections, ArrowResults, TimeRemain))
	spawn_board()

func update_current_attack_board(event_tag: StringName, payload: Variant) -> void:
	if event_tag == tags.Ability_Spawnarrowboard_Result:
		var spawn_result : ga_spawn_arrow_board.ResultArrowBoardPayload = payload
		if is_instance_valid(spawn_result):
			if spawn_result.tag == tags.Arrowboard_Normal:
				current_attack_board = spawn_result.arrow_board
				current_attack_board.Logic.input_pressed.connect(_attack_board_press)
				current_attack_board.Logic.input_finished.connect(_attack_board_finish)

func _gameplay_event_received(event_tag: StringName, payload: Variant) -> void:
	update_current_attack_board(event_tag, payload)

func dead() -> void:
	get_tree().paused = true
	if dead_widget_scene.can_instantiate():
		var new_dead_widget := dead_widget_scene.instantiate()
		get_tree().current_scene.add_child(new_dead_widget)

func _on_attribute_change(attribute_name: String, old_value: float, new_value: float, effect_spec: GameplayEffectSpec) -> void:
	if attribute_name == "current_health":
		if new_value <= 0:
			dead()
			
func _init() -> void:
	add_to_group("Persist")
			
func _ready() -> void:
	for ab in abilities:
		var loaded_ability : GameplayAbility = ab.instantiate()
		asc.grant_ability(loaded_ability)
	for ef in effects:
		asc.apply_gameplay_effect(ef, asc, 1.0)
	asc.gameplay_event_received.connect(_gameplay_event_received)
	asc.attribute_changed.connect(_on_attribute_change)
	if SaveGameManager.current_save_data.has(get_script().get_global_name()):
		load_game(SaveGameManager.current_save_data[get_script().get_global_name()])

func _input(event: InputEvent) -> void:
	if ah_inputs.is_inputting_arrow_keys(event):
		asc.send_gameplay_event(tags.Ability_Arrowinput, event)

func round_start() -> void:
	is_round_start = true
	spawn_board()

func round_end() -> void:
	is_round_start = false
	destroy_board()
