## An extended class for the attribute module: Base 
##
## @meta_addon: GodotGAS 1.0.5
## @meta_author: YulRun (https://YulRun.Dev) & 'Your Name Here'
## @meta_license: MIT (Default)

@tool
class_name BaseAttributeSet extends AttributeSet

@export var max_health: AttributeData = AttributeData.new(25.0)
@export var current_health: AttributeData = AttributeData.new(25.0)
@export var max_shield: AttributeData = AttributeData.new(5.0)
@export var current_shield: AttributeData = AttributeData.new(5.0)
@export var base_damage: AttributeData = AttributeData.new(1.0)
@export var time_period: AttributeData = AttributeData.new(3.0)
@export var finish_heal: AttributeData = AttributeData.new(0.0)
@export var finish_regen: AttributeData = AttributeData.new(1.0)
@export var gold: AttributeData = AttributeData.new(0.0)

var tr_max_health = tr("max_health")
var tr_current_health = tr("current_health")
var tr_max_shield = tr("max_shield")
var tr_current_shield = tr("current_shield")
var tr_base_damage = tr("base_damage")
var tr_time_period = tr("time_period")
var tr_finish_heal = tr("finish_heal")
var tr_finish_regen = tr("finish_regen")
var tr_gold = tr("gold")

## The safety pipeline: Clamps stats before they are officially changed.
func pre_attribute_change(attribute_name: String, proposed_value: float) -> float:
	match attribute_name:
		_:
			pass

	return proposed_value

## The reaction pipeline: Handles moving goalposts (e.g. MaxHealth dropping below Health).
func post_attribute_change(asc: Node, attribute_name: String, old_value: float, new_value: float) -> void:
	var delta : float = new_value - old_value
	match attribute_name:
		"current_health":
			current_health.current_value = clampf(current_health.current_value, 0, max_health.current_value)
		"max_health":
			current_health.current_value = clampf(current_health.current_value + delta, 0, max_health.current_value)
		"current_shield":
			current_shield.current_value = clampf(current_shield.current_value, 0, max_shield.current_value)
		"max_shield":
			current_shield.current_value = clampf(current_shield.current_value + delta, 0, max_shield.current_value)
