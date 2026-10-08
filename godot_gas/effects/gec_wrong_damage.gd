extends GameplayExecutionCalculation

class_name GEC_WrongDamage

func execute(spec: GameplayEffectSpec, target_asc: AbilitySystemComponent) -> Dictionary:
	var asc : AbilitySystemComponent = spec.context.causer.get_node("AbilitySystemComponent")
	var wrong_damage : float = asc.get_attribute("wrong_damage").current_value
	return EffectCalculation.calculate_damage(wrong_damage, target_asc)
