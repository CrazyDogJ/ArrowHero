## An extended class for the attribute module: ArrowWeights 
##
## @meta_addon: GodotGAS 1.0.5
## @meta_author: YulRun (https://YulRun.Dev) & 'Your Name Here'
## @meta_license: MIT (Default)

@tool
class_name ArrowWeightsAttributeSet extends AttributeSet

@export var up_weight: AttributeData = AttributeData.new(1.0)
@export var right_weight: AttributeData = AttributeData.new(1.0)
@export var down_weight: AttributeData = AttributeData.new(1.0)
@export var left_weight: AttributeData = AttributeData.new(1.0)
@export var arrow_num: AttributeData = AttributeData.new(4.0)
@export var wrong_damage: AttributeData = AttributeData.new(1.0)

var tr_up_weight = tr("up_weight")
var tr_right_weight = tr("right_weight")
var tr_down_weight = tr("down_weight")
var tr_left_weight = tr("left_weight")
var tr_arrow_num = tr("arrow_num")
var tr_wrong_damage = tr("wrong_damage")

func get_arrow_weights() -> Array[float]:
	return [up_weight.current_value, right_weight.current_value, down_weight.current_value, left_weight.current_value]

## The safety pipeline: Clamps stats before they are officially changed.
func pre_attribute_change(attribute_name: String, proposed_value: float) -> float:
	match attribute_name:
		_:
			pass

	return proposed_value


## The reaction pipeline: Handles moving goalposts (e.g. MaxHealth dropping below Health).
func post_attribute_change(asc: Node, attribute_name: String, old_value: float, new_value: float) -> void:
	match attribute_name:
		_:
			pass
