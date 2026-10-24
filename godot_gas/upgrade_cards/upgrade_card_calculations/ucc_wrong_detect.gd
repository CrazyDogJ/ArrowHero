class_name UCC_WrongDetect extends UpgradeCardCalculation

@export var apply_to_target : bool = true
@export var gameplay_effect : GameplayEffect
@export var gameplay_effect_level : float = 1.0

func _on_arrow_board_finish(in_payload : ArrowBoardFinishPayload, in_asc : AbilitySystemComponent, target_asc : AbilitySystemComponent) -> void:
	var wrong_times : int = 0
	for result in in_payload.ArrowResults:
		if result == enums.ArrowState.Wrong:
			wrong_times += 1
	
	if is_instance_valid(in_asc):
		if apply_to_target and is_instance_valid(target_asc):
			var instigator : MainPlayer = in_asc.get_parent()
			if is_instance_valid(instigator):
				var spec = GameplayEffectSpec.new(
					gameplay_effect, new_context(instigator, in_payload.Card), 
					wrong_times * gameplay_effect_level)
				in_asc.apply_effect_spec_to_target(spec, target_asc)
		else:
			in_asc.apply_gameplay_effect(gameplay_effect, in_asc, wrong_times * gameplay_effect_level)
