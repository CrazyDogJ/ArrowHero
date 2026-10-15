class_name AttributeDisplay extends Resource

const enums := preload("res://Scripts/enums.gd")

@export var attribute_name : String
@export var display_type : enums.AttributeDisplayType
@export var other_attribute_name : Array[String]
