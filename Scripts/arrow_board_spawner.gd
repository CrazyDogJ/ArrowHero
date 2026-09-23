extends Node2D

@export var arrow_board_prefab : PackedScene
@export var seed_generator : GameRandomGenerator
@export var root_node : CanvasItem

func spawn_arrow_board(ArrowNum : int) -> ArrowBoard:
	if arrow_board_prefab.can_instantiate():
		var newBoard : ArrowBoard = arrow_board_prefab.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
		if is_instance_valid(newBoard):
			newBoard.RandomGenerator = seed_generator
			newBoard.ArrowNums = ArrowNum
			return newBoard
	return null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var newBoard = spawn_arrow_board(4)
	if is_instance_valid(newBoard) and is_instance_valid(root_node):
		root_node.add_child.call_deferred(newBoard)
		newBoard.set_position(get_position())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
