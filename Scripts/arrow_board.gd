extends RigidBody2D

class_name ArrowBoard

const enums := preload("res://Scripts/enums.gd")

@export var ArrowPrefab : PackedScene

@export var TimeToDie : float = 2.0
@export var IsDying : bool = false

@export_category("Instances")
@export var Logic : ArrowBoardLogic
@export var AudioPlayer : RandomAudioStreamPlayer
@export var TimeBar : ColorRect
@export var ArrowContainer : HBoxContainer

@export_category("Arrow Sounds")
@export var CorrectSounds : Array[AudioStream]
@export var WrongSounds : Array[AudioStream]

@export_category("Arrow Textures")
@export var ArrowUp : Texture2D
@export var ArrowRight : Texture2D
@export var ArrowDown : Texture2D
@export var ArrowLeft : Texture2D

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
	if is_instance_valid(ArrowContainer):
		var newInstance: TextureRect = spawn_arrow(InDirection)
		if is_instance_valid(newInstance):
			# make sure to add child successfully
			ArrowContainer.add_child(newInstance)

func set_arrow_state(InIndex : int, InState : enums.ArrowState) -> void:
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
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	if is_instance_valid(RandomGenerator):
		var physRng: RandomNumberGenerator = RandomGenerator.get_rng_safe("physics")
		var dx: bool = physRng.randi_range(0, 1)
		var dxm: int = 1 if dx else -1
		var x: float = physRng.randf_range(30, 100)
		var y: float = physRng.randf_range(-200, -300)
		var rot: float = physRng.randf_range(-3, 3)
		apply_torque_impulse(rot)
		apply_central_impulse(Vector2(x * dxm, y))
	get_tree().create_timer(TimeToDie, false).timeout.connect(destroy)

func update_timer_bar(delta: float) -> void:
	if is_instance_valid(TimeBar) and is_instance_valid(Logic):
		var ratio := 0.0
		if Logic.PeriodTime > 0.0:
			ratio = clampf(Logic.CurrentTime / Logic.PeriodTime, 0.0, 1.0)
		TimeBar.set_instance_shader_parameter("progress", ratio)

func play_input_sound(is_match : bool) -> void:
	if is_instance_valid(AudioPlayer):
		if is_match:
			AudioPlayer.play_random_sound(CorrectSounds)
		else:
			AudioPlayer.play_random_sound(WrongSounds)

func arrow_directions_ready(arrow_directions : Array[enums.ArrowDirection]) -> void:
	for i in arrow_directions:
		add_arrow_to_box(i)

func destroy() -> void:
	queue_free()
	
func _ready() -> void:
	if is_instance_valid(Logic):
		arrow_directions_ready(Logic.CurrentArrowArray)
		Logic.input_pressed.connect(on_input_pressed)
		Logic.input_finished.connect(on_input_finished)

func _process(delta: float) -> void:
	update_timer_bar(delta)

func on_input_pressed(CurrentInputingIndex : int, ArrowDirection: enums.ArrowDirection, ArrowResult: enums.ArrowState) -> void:
	set_arrow_state(CurrentInputingIndex, ArrowResult)
	play_input_sound(ArrowResult == enums.ArrowState.Correct)
	
func on_input_finished(ArrowDirections: Array[enums.ArrowDirection], ArrowResults: Array[enums.ArrowState], RemainTime : float) -> void:
	input_finish()
