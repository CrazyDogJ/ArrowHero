class_name EffectCalculation

static func calculate_damage(damage : float, asc : AbilitySystemComponent) -> Dictionary:
	if is_instance_valid(asc):
		var cs = asc.get_attribute("current_shield").current_value
		## var ch = asc.get_attribute("current_health").current_value
		if cs >= damage:
			return { "current_shield": -damage }
		else:
			return { "current_shield": -cs, "current_health": -(damage - cs) }
	return {}
