extends GameplayExecutionCalculation

class_name GEC_Attack

func try_get_card(spec: GameplayEffectSpec) -> UpgradeCard:
	for result in spec.context.target_data._hit_results:
		var card : UpgradeCard = result.get("card") as UpgradeCard
		if is_instance_valid(card):
			return card
	return null

func execute(spec: GameplayEffectSpec, target_asc: AbilitySystemComponent) -> Dictionary:
	var value : float = spec.level
	var causer_player : MainPlayer = spec.context.causer
	var card_def := try_get_card(spec)
	if is_instance_valid(causer_player):
		var icon : Texture2D = card_def.card_icon if is_instance_valid(card_def) else null
		GlobalVars.spawn_damage_number(causer_player.damage_number_spawn_node, Vector2(0,0), int(value), icon)
	return EffectCalculation.calculate_damage(value, target_asc)
