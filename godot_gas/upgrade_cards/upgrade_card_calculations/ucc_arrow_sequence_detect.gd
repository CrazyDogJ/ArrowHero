class_name UCC_ArrowSequenceDetect extends UpgradeCardCalculation

@export var apply_to_target : bool = true
@export var gameplay_effect : GameplayEffect
@export var gameplay_effect_level : float = 1.0
@export var arrow_sequence : Array[enums.ArrowDirection]

func _on_arrow_board_finish(in_payload : ArrowBoardFinishPayload, in_asc : AbilitySystemComponent, target_asc : AbilitySystemComponent) -> void:
	if arrow_sequence.is_empty():
		return
	var times : int = 0
	var checking_index : int = 0
	for direction in in_payload.ArrowDirections:
		if direction == arrow_sequence[checking_index]:
			## Check index is the last
			if checking_index == arrow_sequence.size() - 1:
				times += 1
				checking_index = 0
			else:
				checking_index += 1
		else:
			checking_index = 0
	
	if is_instance_valid(in_asc):
		if apply_to_target and is_instance_valid(target_asc):
			var instigator : MainPlayer = in_asc.get_parent()
			if is_instance_valid(instigator):
				var spec = GameplayEffectSpec.new(
					gameplay_effect, new_context(instigator, in_payload.Card), 
					times * gameplay_effect_level)
				in_asc.apply_effect_spec_to_target(spec, target_asc)
		else:
			in_asc.apply_gameplay_effect(gameplay_effect, in_asc, times * gameplay_effect_level)
