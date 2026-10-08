extends GameplayExecutionCalculation

class_name GEC_EnemyAttack

func execute(spec: GameplayEffectSpec, target_asc: AbilitySystemComponent) -> Dictionary:
	var asc : AbilitySystemComponent = spec.context.causer.get_node("AbilitySystemComponent")
	var value : float = asc.get_attribute("base_damage").current_value
	return EffectCalculation.calculate_damage(value, target_asc)
