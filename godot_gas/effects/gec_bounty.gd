extends GameplayExecutionCalculation

class_name GEC_Bounty

func execute(spec: GameplayEffectSpec, target_asc: AbilitySystemComponent) -> Dictionary:
	var asc : AbilitySystemComponent = spec.context.causer.get_node("AbilitySystemComponent")
	var value : float = asc.get_attribute("gold").current_value
	var random_floating : int = spec.level
	var delta : int = RandomGenerator.get_loot_rng_safe().randi_range(-random_floating, random_floating)
	var final_gold : float = maxi(value + delta, 0)
	return { "gold": final_gold }
