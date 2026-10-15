## An extended class for the attribute module: Round 
##
## @meta_addon: GodotGAS 1.0.5
## @meta_author: YulRun (https://YulRun.Dev) & 'Your Name Here'
## @meta_license: MIT (Default)

@tool
class_name RoundAttributeSet extends AttributeSet

@export var round_time: AttributeData = AttributeData.new(60.0)
@export var current_round_time: AttributeData = AttributeData.new(60.0)
@export var current_day: AttributeData = AttributeData.new(1.0)
@export var target_distance: AttributeData = AttributeData.new(5.0)
@export var current_distance: AttributeData = AttributeData.new(0.0)

var tr_round_time = tr("round_time")
var tr_current_round_time = tr("current_round_time")
var tr_current_day = tr("current_day")
var tr_target_distance = tr("target_distance")
var tr_current_distance = tr("current_distance")

## The safety pipeline: Clamps stats before they are officially changed.
func pre_attribute_change(attribute_name: String, proposed_value: float) -> float:
	match attribute_name:
		_:
			pass

	return proposed_value


## The reaction pipeline: Handles moving goalposts (e.g. MaxHealth dropping below Health).
func post_attribute_change(asc: Node, attribute_name: String, old_value: float, new_value: float) -> void:
	match attribute_name:
		"current_round_time":
			current_round_time._set_base_value(maxf(new_value, 0))
