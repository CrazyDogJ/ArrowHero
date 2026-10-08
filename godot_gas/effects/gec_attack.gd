extends GameplayExecutionCalculation

class_name GEC_Attack

func execute(spec: GameplayEffectSpec, target_asc: AbilitySystemComponent) -> Dictionary:
	var value : float = spec.level
	return EffectCalculation.calculate_damage(value, target_asc)
