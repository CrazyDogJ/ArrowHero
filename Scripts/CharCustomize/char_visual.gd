@tool
class_name CharVisual extends Node

@export var head_pivot : Node
@export var head_prefab : PackedScene:
	set(value):
		head_prefab = value
		update_head_prefab()
var head_instance : HeadDesc

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var root_skeleton : Skeleton2D = $Skeleton2D
var moving_right : bool = true:
	set(value):
		moving_right = value
		if is_instance_valid(root_skeleton):
			root_skeleton.scale = Vector2(1 if moving_right else -1, 1)

func get_move_amount() -> float:
	if is_instance_valid(animation_tree):
		return animation_tree.get("parameters/Move/blend_position")
	return 0.0

func set_move_amount(move: float) -> void:
	if is_instance_valid(animation_tree):
		animation_tree.set("parameters/Move/blend_position", move)

func update_head_prefab() -> void:
	if is_instance_valid(head_instance):
		head_instance.queue_free()
		head_instance = null
	if is_instance_valid(head_pivot):
		if head_prefab != null and head_prefab.can_instantiate():
			head_instance = head_prefab.instantiate() as HeadDesc
			head_pivot.add_child(head_instance)

func _ready() -> void:
	update_head_prefab()

func _process(delta: float) -> void:
	pass
