extends Node

class_name Enemy

signal enemy_dead(attribute_name: String, old_value: float, new_value: float, effect_spec: GameplayEffectSpec)

@onready var asc : AbilitySystemComponent = $AbilitySystemComponent

@export var attack_effect : GameplayEffect
@export var bounty_effect : GameplayEffect
@export var bounty_floating : int = 5

var current_time : float
var target_asc : AbilitySystemComponent

func get_ability_component() -> AbilitySystemComponent:
	if is_instance_valid(asc):
		return asc
	else:
		return get_node("AbilitySystemComponent")

func reset_current_time() -> void:
	current_time = asc.get_attribute("time_period").current_value

func time_end() -> void:
	if is_instance_valid(target_asc):
		var instigator = asc.get_parent() if asc else get_parent()
		var context = GameplayEffectContext.new(instigator)
		var spec = GameplayEffectSpec.new(attack_effect, context, 1.0)
		asc.apply_effect_spec_to_target(spec, target_asc)
	reset_current_time()

func give_gold(give_to_asc : AbilitySystemComponent) -> void:
	# Create a basic context and spec so the developer doesn't have to do it manually every time
	var instigator = get_ability_component().get_parent() if get_ability_component() else get_parent()
	var context = GameplayEffectContext.new(instigator)
	var spec = GameplayEffectSpec.new(bounty_effect, context, bounty_floating)
	get_ability_component().apply_effect_spec_to_target(spec, give_to_asc)

func dead(attribute_name: String, old_value: float, new_value: float, effect_spec: GameplayEffectSpec) -> void:
	var source_asc : AbilitySystemComponent = effect_spec.context.causer.get_node("AbilitySystemComponent")
	if is_instance_valid(source_asc):
		give_gold(source_asc)
	if is_instance_valid(GlobalVars.round_time):
		GlobalVars.round_time.add_distance()
	queue_free()

func _on_attribute_change(attribute_name: String, old_value: float, new_value: float, effect_spec: GameplayEffectSpec) -> void:
	if attribute_name == "current_health":
		if new_value <= 0:
			enemy_dead.emit(attribute_name, old_value, new_value, effect_spec)
			dead(attribute_name, old_value, new_value, effect_spec)

func _ready() -> void:
	reset_current_time()
	asc.attribute_changed.connect(_on_attribute_change)

func _process(delta: float) -> void:
	current_time = maxf(current_time - delta, 0)
	if current_time <= 0:
		time_end()
