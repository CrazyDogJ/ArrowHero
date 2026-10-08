class_name StatLabel extends Label

const enums := preload("res://Scripts/enums.gd")

var asc : AbilitySystemComponent
var attribute_name : String
var display_type : enums.AttributeDisplayType

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(asc):
		var attribute := asc.get_attribute(attribute_name)
		if display_type == enums.AttributeDisplayType.Float:
			text = "%s : %s" % [tr(attribute_name), str(attribute.current_value)]
		else:
			text = "%s : %d" % [tr(attribute_name), attribute.current_value]
