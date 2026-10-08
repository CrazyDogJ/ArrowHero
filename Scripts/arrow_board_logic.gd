extends Node

class_name ArrowBoardLogic

const enums := preload("res://Scripts/enums.gd")
const ah_inputs := preload("res://Scripts/ah_input.gd")

signal input_finished(ArrowDirections : Array[enums.ArrowDirection], ArrowResults : Array[enums.ArrowState], TimeRemain : float)
signal input_pressed(Index : int, ArrowDirection : enums.ArrowDirection, ArrowResult : enums.ArrowState)

@export var CurrentInputtingIndex : int = 0
@export var CurrentArrowArray : Array[enums.ArrowDirection]
@export var CurrentArrowResult : Array[enums.ArrowState]

@export var ArrowWeights : Array[float] = [1,1,1,1]
@export var ArrowNums : int = 1
@export var PeriodTime : float = 3.0

@onready var CurrentTime : float = PeriodTime

func is_current_input_match(event: InputEvent) -> bool:
	# make sure current input index is inside the array range.
	if CurrentArrowArray.size() > CurrentInputtingIndex:
		var InputDirection : enums.ArrowDirection = ah_inputs.get_input_direction(event)
		if CurrentArrowArray.get(CurrentInputtingIndex) == InputDirection:
			return true
	return false

func update_timer(delta: float) -> void:
	CurrentTime -= delta
	if CurrentTime <= 0:
		finish()

func finish() -> void:
	input_finished.emit(CurrentArrowArray, CurrentArrowResult, CurrentTime)
	queue_free()

func _ready() -> void:
	set_process_input(false)
	CurrentArrowArray = RandomGenerator.generate_arrows(ArrowNums, ArrowWeights)
	CurrentArrowResult.resize(CurrentArrowArray.size())
			
func _input(event: InputEvent) -> void:
	if ah_inputs.is_inputting_arrow_keys(event):
		var is_match : bool = is_current_input_match(event)
		CurrentArrowResult[CurrentInputtingIndex] = enums.ArrowState.Correct if is_match else enums.ArrowState.Wrong
		input_pressed.emit(CurrentInputtingIndex, CurrentArrowArray[CurrentInputtingIndex], CurrentArrowResult[CurrentInputtingIndex])
		if CurrentInputtingIndex < CurrentArrowArray.size() - 1:
			CurrentInputtingIndex += 1
		else:
			finish()

func _process(delta: float) -> void:
	update_timer(delta)
