class_name UpgradeCardsManager extends Node

var asc_owner : Node
var asc : AbilitySystemComponent

var round_time : RoundTime
var round_time_asc : AbilitySystemComponent

var active_cards : Array[ActiveGameplayEffect]

func _ready() -> void:
	asc_owner = get_parent()
	if is_instance_valid(asc_owner):
		asc = asc_owner.get_node("AbilitySystemComponent")
	round_time = asc_owner.get_parent().get_node("RoundTime")
	if is_instance_valid(round_time):
		round_time_asc = round_time.get_node("AbilitySystemComponent")

func add_card(in_card : UpgradeCard) -> void:
	if is_instance_valid(in_card):
		if in_card.is_round_time:
			if is_instance_valid(round_time_asc):
				var active_card : ActiveGameplayEffect = asc.apply_gameplay_effect(in_card, round_time_asc)
				if is_instance_valid(active_card):
					active_cards.push_back(active_card)
		else:
			if is_instance_valid(asc):
				var active_card : ActiveGameplayEffect = asc.apply_gameplay_effect(in_card, asc)
				if is_instance_valid(active_card):
					active_cards.push_back(active_card)

func remove_card(active_effect : ActiveGameplayEffect) -> void:
	if is_instance_valid(active_effect):
		asc.remove_active_effect(active_effect)
		active_cards.erase(active_effect)
