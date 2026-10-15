class_name UpgradeCard extends GameplayEffect

@export var card_name : String
@export var card_desc : String = "{DEFAULT}"
@export var card_icon : Texture2D
@export var card_base_price : int
@export var card_floating_price : int
@export var card_store_weight : float = 1.0

@export var is_round_time : bool = false

const uccp := preload("res://godot_gas/upgrade_cards/upgrade_card_calculation.gd")
@export var upgrade_card_calculation : UpgradeCardCalculation

func _init() -> void:
	policy = DurationPolicy.INFINITE

func handle_arrow_input(input_payload : uccp.ArrowInputPayload, asc : AbilitySystemComponent, target_asc : AbilitySystemComponent) -> void:
	if is_instance_valid(upgrade_card_calculation):
		upgrade_card_calculation._on_arrow_input(input_payload, asc, target_asc)
		
func handle_arrow_finish(finish_payload : uccp.ArrowBoardFinishPayload, asc : AbilitySystemComponent, target_asc : AbilitySystemComponent) -> void:
	if is_instance_valid(upgrade_card_calculation):
		upgrade_card_calculation._on_arrow_board_finish(finish_payload, asc, target_asc)

func make_text(raw_string : String) -> String:
	var result : String = ""
	for modifier in modifiers:
		var att_loc_name : String = tr(modifier.attribute_name)
		var att_mod_value : float = modifier.calculate_magnitude()
		var is_add : bool = att_mod_value > 0
		var att_op_name : String
		match modifier.operation:
			modifier.Operation.ADD: att_op_name = "+" if is_add else "-"
			modifier.Operation.MULTIPLY: att_op_name = "×"
			modifier.Operation.DIVIDE: att_op_name = "÷"
			modifier.Operation.OVERRIDE: att_op_name = tr("override")
		var modifier_string : String = "%s %s %d" % [att_loc_name, att_op_name, att_mod_value]
		result += modifier_string
	return raw_string.replace("{DEFAULT}", result)
