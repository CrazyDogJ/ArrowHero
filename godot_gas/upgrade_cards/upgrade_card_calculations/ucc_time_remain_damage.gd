class_name UCC_TimeRemainDamage extends UpgradeCardCalculation

@export var damage_multiplier : float = 1

func _on_arrow_board_finish(in_payload : ArrowBoardFinishPayload, in_asc : AbilitySystemComponent, target_asc : AbilitySystemComponent) -> void:
	var damage = round(in_payload.TimeRemain * damage_multiplier)
	if is_instance_valid(in_asc) and is_instance_valid(target_asc):
		var instigator : MainPlayer = in_asc.get_parent()
		if is_instance_valid(instigator):
			var spec = GameplayEffectSpec.new(instigator.attack_effect, new_context(instigator, in_payload.Card), damage)
			in_asc.apply_effect_spec_to_target(spec, target_asc)
