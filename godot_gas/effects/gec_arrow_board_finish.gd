extends GameplayExecutionCalculation

class_name GEC_ArrowBoardFinish

func execute(spec: GameplayEffectSpec, target_asc: AbilitySystemComponent) -> Dictionary:
	var asc : AbilitySystemComponent = spec.context.causer.get_node("AbilitySystemComponent")
	var finish_heal : float = asc.get_attribute("finish_heal").current_value
	var finish_regen : float = target_asc.get_attribute("finish_regen").current_value
	return { "current_health": finish_heal, "current_shield": finish_regen  }
