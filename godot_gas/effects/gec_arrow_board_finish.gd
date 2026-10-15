extends GameplayExecutionCalculation

class_name GEC_ArrowBoardFinish

func execute(spec: GameplayEffectSpec, target_asc: AbilitySystemComponent) -> Dictionary:
	var player : MainPlayer = spec.context.causer as MainPlayer
	var asc : AbilitySystemComponent = spec.context.causer.get_node("AbilitySystemComponent")
	var finish_heal : float = asc.get_attribute("finish_heal").current_value
	var finish_regen : float = target_asc.get_attribute("finish_regen").current_value
	if is_instance_valid(player):
		GlobalVars.spawn_damage_number(player.self_damage_number_spawn_node, Vector2(0,0), int(finish_heal), null, Color.GREEN)
		GlobalVars.spawn_damage_number(player.self_damage_number_spawn_node, Vector2(0,0), int(finish_regen), null, Color.SKY_BLUE)
	return { "current_health": finish_heal, "current_shield": finish_regen  }
