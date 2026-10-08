## An extended class for the attribute module: Store 
##
## @meta_addon: GodotGAS 1.0.5
## @meta_author: YulRun (https://YulRun.Dev) & 'Your Name Here'
## @meta_license: MIT (Default)

@tool
class_name StoreAttributeSet extends AttributeSet

@export var free_refresh: AttributeData = AttributeData.new(1.0)
@export var store_item_num: AttributeData = AttributeData.new(3.0)

var tr_free_refresh = tr("free_refresh")
var tr_store_item_num = tr("store_item_num")

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
