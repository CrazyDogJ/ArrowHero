class_name RoundEndStore extends Node

class UpgradeCardStoreItem:
	func _init(in_card : UpgradeCard, in_price : int) -> void:
		card = in_card
		price = in_price
	var card : UpgradeCard
	var price : int

@export var cards : UpgradeCards
var cards_in_store : Array[UpgradeCardStoreItem]
@export var asc_owner : Node
@export var asc : AbilitySystemComponent
@export var buy_effect : GameplayEffect
var cards_manager : UpgradeCardsManager
var current_refresh_times : int

@export var store_item_prefab : PackedScene
@export var hbox : HBoxContainer

@export var refresh_button : Button
@export var continue_button : Button

func get_asc() -> AbilitySystemComponent:
	if not is_instance_valid(asc):
		if is_instance_valid(asc_owner):
			asc = asc_owner.get_node("AbilitySystemComponent")
	return asc

func get_cards_manager() -> UpgradeCardsManager:
	if not is_instance_valid(cards_manager):
		if is_instance_valid(asc_owner):
			cards_manager = asc_owner.get_node("UpgradeCardsManager")
	return cards_manager

func get_store_free_refresh_times() -> int:
	if is_instance_valid(get_asc()):
		return int(asc.get_attribute("free_refresh").current_value)
	return 1

func get_store_num() -> int:
	if is_instance_valid(get_asc()):
		return int(asc.get_attribute("store_item_num").current_value)
	return 3

func get_store_items(num : int) -> Array[UpgradeCardStoreItem]:
	var result : Array[UpgradeCardStoreItem]
	if is_instance_valid(cards):
		for i in range(num):
			var index = RandomGenerator.get_rng_safe("store").rand_weighted(cards.get_cards_weights())
			var card = cards.cards[index]
			var price = RandomGenerator.get_rng_safe("store").randi_range(card.card_base_price - card.card_floating_price, card.card_base_price + card.card_floating_price)
			var new_store_item : UpgradeCardStoreItem = UpgradeCardStoreItem.new(card, price)
			result.push_back(new_store_item)
	return result

func update_hbox() -> void:
	if is_instance_valid(hbox) and store_item_prefab.can_instantiate():
		for card in cards_in_store:
			var store_item : StoreItem = store_item_prefab.instantiate()
			store_item.asc = get_asc()
			store_item.card = card.card
			store_item.price = card.price
			store_item.is_selling = false
			store_item.on_interact_button_press.connect(_on_item_interact)
			hbox.add_child(store_item)

func buy_item(interacting_item : StoreItem) -> void:
	if not is_instance_valid(interacting_item):
		return
	var price : int = interacting_item.price
	if is_instance_valid(get_asc()):
		var owning_gold : int = int(asc.get_attribute("gold").current_value)
		if owning_gold >= price:
			get_cards_manager()
			if is_instance_valid(cards_manager) and is_instance_valid(interacting_item.card):
				cards_manager.add_card(interacting_item.card)
			if is_instance_valid(asc):
				asc.apply_gameplay_effect(buy_effect, asc, -price)
			interacting_item.queue_free()

func refresh_items() -> void:
	if is_instance_valid(hbox):
		if current_refresh_times > 0:
			for child in hbox.get_children():
				child.queue_free()
			cards_in_store = get_store_items(get_store_num())
			update_hbox()
			current_refresh_times -= 1

func _on_item_interact(interacting_item : StoreItem) -> void:
	if is_instance_valid(interacting_item):
		if not interacting_item.is_selling:
			buy_item(interacting_item)

func _on_refresh_pressed() -> void:
	refresh_items()

func _ready() -> void:
	if is_instance_valid(continue_button):
		continue_button.text = tr("continue")
	current_refresh_times = get_store_free_refresh_times()
	if is_instance_valid(refresh_button):
		refresh_button.pressed.connect(_on_refresh_pressed)
	cards_in_store = get_store_items(get_store_num())
	update_hbox()

func _process(delta: float) -> void:
	if is_instance_valid(refresh_button):
		refresh_button.text = tr("refresh") + "(" + str(current_refresh_times) + ")"
		refresh_button.disabled = current_refresh_times <= 0
		
