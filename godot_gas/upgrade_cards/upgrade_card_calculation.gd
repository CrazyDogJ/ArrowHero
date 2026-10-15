class_name UpgradeCardCalculation extends Resource

const enums := preload("res://Scripts/enums.gd")

class ArrowInputPayload:
	func _init(card : UpgradeCard, i : int, d : enums.ArrowDirection, s : enums.ArrowState) -> void:
		Card = card
		ArrowIndex = i
		ArrowDirection = d
		ArrowState = s
	var Card : UpgradeCard
	var ArrowIndex : int
	var ArrowDirection : enums.ArrowDirection
	var ArrowState : enums.ArrowState

class ArrowBoardFinishPayload:
	func _init(card : UpgradeCard, d : Array[enums.ArrowDirection], s : Array[enums.ArrowState] , rt : float) -> void:
		Card = card
		ArrowDirections = d
		ArrowResults = s
		TimeRemain = rt
	var Card : UpgradeCard
	var ArrowDirections : Array[enums.ArrowDirection]
	var ArrowResults : Array[enums.ArrowState] 
	var TimeRemain : float

func new_context(instigator : Node, card : UpgradeCard) -> GameplayEffectContext:
	var context = GameplayEffectContext.new(instigator)
	context.target_data._hit_results.push_back({"card" : card})
	return context

func _on_arrow_input(input_payload : ArrowInputPayload, in_asc : AbilitySystemComponent, target_asc : AbilitySystemComponent) -> void:
	pass
	
func _on_arrow_board_finish(in_payload : ArrowBoardFinishPayload, in_asc : AbilitySystemComponent, target_asc : AbilitySystemComponent) -> void:
	pass
