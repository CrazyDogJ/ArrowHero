extends GameplayExecutionCalculation

class_name GEC_Bounty

@export var coin_icon : Texture2D = preload("res://Textures/T_Coin.png")

func execute(spec: GameplayEffectSpec, target_asc: AbilitySystemComponent) -> Dictionary:
	var asc : AbilitySystemComponent = spec.context.causer.get_node("AbilitySystemComponent")
	var value : float = asc.get_attribute("gold").current_value
	var random_floating : int = int(spec.level)
	var delta : int = RandomGenerator.get_rng_safe("loot").randi_range(-random_floating, random_floating)
	var final_gold : float = maxi(int(value) + delta, 0)
	var player : MainPlayer = target_asc.get_parent()
	if is_instance_valid(player):
		GlobalVars.spawn_damage_number(player.self_damage_number_spawn_node, Vector2(0,0), int(final_gold), coin_icon, Color.YELLOW)
	return { "gold": final_gold }
