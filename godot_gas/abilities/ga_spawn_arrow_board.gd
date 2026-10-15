extends GameplayAbility

@export var arrow_board_prefab : PackedScene

const tags = preload("res://godot_gas/gameplay_tags.gd")

class SpawnArrowBoardPayload:
	var scene_root : Node
	var location_node : CanvasItem
	var tag : StringName
	func _init(iscene_root : Node, ilocation_node : CanvasItem, itag : StringName) -> void:
		scene_root = iscene_root
		location_node = ilocation_node
		tag = itag

class ResultArrowBoardPayload:
	var arrow_board : ArrowBoard
	var tag : StringName
	func _init(iarrow_board : ArrowBoard, itag : StringName) -> void:
		arrow_board = iarrow_board
		tag = itag

func _init() -> void:
	trigger_event_tag = tags.Ability_Spawnarrowboard_Input
	
func get_owner_asc_arrow_weights() -> Array[float]:
	var weights : Array[float] = [1,1,1,1]
	if is_instance_valid(owner_asc):
		for aset : AttributeSet in owner_asc.attribute_sets:
			var wset : ArrowWeightsAttributeSet = aset as ArrowWeightsAttributeSet
			if is_instance_valid(wset):
				weights = wset.get_arrow_weights()
				break
	return weights

func new_arrow_board() -> ArrowBoard:
	if arrow_board_prefab.can_instantiate():
		var newBoard : ArrowBoard = arrow_board_prefab.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
		if is_instance_valid(newBoard):
			var weights = get_owner_asc_arrow_weights()
			var arrow_num = owner_asc.get_attribute("arrow_num").current_value
			var period = owner_asc.get_attribute("time_period").current_value
			
			newBoard.Logic.ArrowNums = int(arrow_num)
			newBoard.Logic.ArrowWeights = weights
			newBoard.Logic.PeriodTime = period
			
			return newBoard
	return null

func spawn_arrow_board(Payload : SpawnArrowBoardPayload) -> void:
	var newBoard: ArrowBoard = new_arrow_board()
	if is_instance_valid(newBoard) and is_instance_valid(Payload.scene_root):
		Payload.scene_root.add_child.call_deferred(newBoard)
		newBoard.set_position(Payload.location_node.get_position())
		var newResult : ResultArrowBoardPayload = ResultArrowBoardPayload.new(newBoard, Payload.tag)
		owner_asc.send_gameplay_event(tags.Ability_Spawnarrowboard_Result, newResult)

func _activate_ability() -> bool:
	var payload : SpawnArrowBoardPayload = current_event_payload
	if is_instance_valid(payload):
		spawn_arrow_board(payload)
	commit_ability()
	end_ability()
	return true
