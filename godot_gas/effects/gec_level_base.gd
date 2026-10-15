extends GameplayExecutionCalculation

class_name GEC_LevelBase

@export var attribute_string : String

func execute(spec: GameplayEffectSpec, target_asc: AbilitySystemComponent) -> Dictionary:
	var value : float = spec.level
	return {attribute_string : value}
