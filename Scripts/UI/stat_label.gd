class_name StatLabel extends Label

const enums := preload("res://Scripts/enums.gd")

var asc : AbilitySystemComponent
var attribute_display : AttributeDisplay

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(asc):
		var attribute := asc.get_attribute(attribute_display.attribute_name)
		if attribute_display.display_type == enums.AttributeDisplayType.Float:
			text = "%s : %s" % [tr(attribute_display.attribute_name), str(attribute.current_value)]
		if attribute_display.display_type == enums.AttributeDisplayType.Int:
			text = "%s : %d" % [tr(attribute_display.attribute_name), attribute.current_value]
		if attribute_display.display_type == enums.AttributeDisplayType.Probability:
			var total_attribute : float = attribute.current_value
			for other in attribute_display.other_attribute_name:
				total_attribute = total_attribute + asc.get_attribute(other).current_value
			text = "%s : %s (%d%s)" % [tr(attribute_display.attribute_name), str(attribute.current_value), attribute.current_value / total_attribute * 100, "%"]
