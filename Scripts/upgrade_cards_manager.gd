class_name UpgradeCardsManager extends Node

var asc_owner : Node
var asc : AbilitySystemComponent

var round_time : RoundTime
var round_time_asc : AbilitySystemComponent

var active_cards : Array[ActiveGameplayEffect]

@export var init_cards : Array[UpgradeCard]

func save_game() -> Dictionary:
	var save_data : Dictionary
	save_data.get_or_add("active_cards", get_cards_path())
	return save_data
	
func load_game(in_data : Dictionary) -> void:
	var cards : Array[String]
	cards.assign(in_data.get("active_cards"))
	clear_cards()
	for card_path in cards:
		var card_object : UpgradeCard = load(card_path) as UpgradeCard
		add_card(card_object)
	
func get_cards_path() -> Array[String]:
	var result : Array[String]
	for card in active_cards:
		result.push_back(card.get_effect_def().resource_path)
	return result
	
func get_cards() -> Array[UpgradeCard]:
	var result : Array[UpgradeCard]
	for card in active_cards:
		result.push_back(card.get_effect_def())
	return result

func _ready() -> void:
	asc_owner = get_parent()
	if is_instance_valid(asc_owner):
		asc = asc_owner.get_node("AbilitySystemComponent")
	round_time = asc_owner.get_parent().get_node("RoundTime")
	if is_instance_valid(round_time):
		round_time_asc = round_time.get_node("AbilitySystemComponent")
	GlobalVars.cards_manager = self
	for init_card in init_cards:
		add_card(init_card)

func _exit_tree() -> void:
	GlobalVars.cards_manager = null

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
		
func clear_cards() -> void:
	var current_cards : Array[ActiveGameplayEffect]
	current_cards.assign(active_cards)
	for card in current_cards:
		remove_card(card)
