class_name StatsLabelList extends Control

const enums := preload("res://Scripts/enums.gd")

@export var stat_label : PackedScene
@export var stats : Array[AttributeDisplay]
@export var asc_owner : Node
@export var asc : AbilitySystemComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not is_instance_valid(asc):
		if is_instance_valid(asc_owner):
			asc = asc_owner.get_node("AbilitySystemComponent")
	if stat_label.can_instantiate() and is_instance_valid(asc):
		for stat in stats:
			var new_label : StatLabel = stat_label.instantiate()
			if is_instance_valid(new_label):
				new_label.asc = asc
				new_label.attribute_display = stat
				add_child(new_label)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
