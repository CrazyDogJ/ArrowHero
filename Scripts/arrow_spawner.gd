extends RigidBody2D

class_name ArrowBoard

const enums := preload("res://Scripts/enums.gd")

signal input_finished(ArrowNums : int, ArrowResults : Array[enums.ArrowState])

@export var ArrowPrefab : PackedScene
@export var ArrowNums : int = 4
@export var CurrentInputingIndex : int = 0
@export var CurrentArrowArray : Array[enums.ArrowDirection]
@export var CurrentArrowResult : Array[enums.ArrowState]
@export var TimeToDie : float = 2.0
@export var IsDying : bool = false

@export_category("Instances")
@export var RandomGenerator : GameRandomGenerator
@export var ArrowContainer : HBoxContainer

@export_category("Arrow Textures")
@export var ArrowUp : Texture2D
@export var ArrowRight : Texture2D
@export var ArrowDown : Texture2D
@export var ArrowLeft : Texture2D

func get_input_direction(event: InputEvent) -> enums.ArrowDirection:
	var result : enums.ArrowDirection = enums.ArrowDirection.Invalid
	if event.is_action_pressed("Up"):
		result = enums.ArrowDirection.Up
	if event.is_action_pressed("Right"):
		result = enums.ArrowDirection.Right
	if event.is_action_pressed("Down"):
		result = enums.ArrowDirection.Down
	if event.is_action_pressed("Left"):
		result = enums.ArrowDirection.Left
	return result

func is_inputing_arrow_keys(event: InputEvent) -> bool:
	return get_input_direction(event) != enums.ArrowDirection.Invalid

func is_current_input_match(event: InputEvent) -> bool:
	# make sure current input index is inside the array range.
	if CurrentArrowArray.size() > CurrentInputingIndex:
		var InputDirection = get_input_direction(event)
		if CurrentArrowArray.get(CurrentInputingIndex) == InputDirection:
			return true
			
	return false

func get_arrow_texture(InDirection : enums.ArrowDirection) -> Texture2D:
	var result : Texture2D
	match InDirection:
		enums.ArrowDirection.Up: result = ArrowUp
		enums.ArrowDirection.Right: result = ArrowRight
		enums.ArrowDirection.Down: result = ArrowDown
		enums.ArrowDirection.Left: result = ArrowLeft
	return result

func spawn_arrow(InDirection : enums.ArrowDirection) -> TextureRect:
	if ArrowPrefab.can_instantiate():
		var OutNode : TextureRect = ArrowPrefab.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
		if is_instance_valid(OutNode):
			OutNode.texture = get_arrow_texture(InDirection)
			OutNode.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			return OutNode
	return null

func add_arrow_to_box(InDirection : enums.ArrowDirection) -> void:
	CurrentArrowResult.push_back(enums.ArrowState.Unhandled)
	if is_instance_valid(ArrowContainer):
		var newInstance = spawn_arrow(InDirection)
		if is_instance_valid(newInstance):
			# make sure to add child successfully
			ArrowContainer.add_child(newInstance)

func set_arrow_state(InIndex : int, InState : enums.ArrowState) -> void:
	CurrentArrowResult[CurrentInputingIndex] = InState
	if is_instance_valid(ArrowContainer):
		var child : TextureRect = ArrowContainer.get_children().get(InIndex)
		if is_instance_valid(child):
			var state_color : Color
			match InState:
				enums.ArrowState.Unhandled:
					state_color = Color(1.0, 1.0, 1.0, 1.0)
				enums.ArrowState.Correct:
					state_color = Color(0.0, 1.0, 0.0, 1.0)
				enums.ArrowState.Wrong:
					state_color = Color(1.0, 0.0, 0.0, 1.0)
			child.set_instance_shader_parameter("color", state_color)

func input_finish() -> void:
	IsDying = true;
	freeze = false;
	if is_instance_valid(RandomGenerator):
		var physRng = RandomGenerator.get_physics_rng_safe()
		var x = physRng.randf_range(-100, 100)
		var y = physRng.randf_range(-200, -300)
		apply_central_impulse(Vector2(x, y))
	get_tree().create_timer(TimeToDie).timeout.connect(_destroy)
	input_finished.emit(ArrowNums, CurrentArrowResult)

func _ready() -> void:
	if is_instance_valid(RandomGenerator):
		CurrentArrowArray = RandomGenerator.generate_arrows(ArrowNums)
		for i in CurrentArrowArray:
			add_arrow_to_box(i)

func _destroy() -> void:
	queue_free()

func _input(event: InputEvent) -> void:
	if is_inputing_arrow_keys(event) and not IsDying:
		var is_match = is_current_input_match(event)
		set_arrow_state(CurrentInputingIndex, enums.ArrowState.Correct if is_match else enums.ArrowState.Wrong)
		if CurrentInputingIndex < CurrentArrowArray.size() - 1:
			CurrentInputingIndex += 1
		else:
			input_finish()
