class_name StoreItem extends Node

@export var card : UpgradeCard
@export var price : int

@export var price_label : Label
@export var upgrade_card_visual : UpgradeCardVisual

@export var interact_button : Button
@export var is_selling : bool = false

@export var asc : AbilitySystemComponent

signal on_interact_button_press(interacting_item : StoreItem)

func _on_pressed() -> void:
	on_interact_button_press.emit(self)

func _ready() -> void:
	if is_instance_valid(interact_button):
		if is_instance_valid(asc):
			var current_gold : int = asc.get_attribute("gold").current_value
			interact_button.disabled = current_gold < price
		interact_button.pressed.connect(_on_pressed)
		if is_selling:
			interact_button.text = tr("sell")
		else:
			interact_button.text = tr("buy")
	if is_instance_valid(price_label):
		price_label.text = str(price)
	if is_instance_valid(upgrade_card_visual):
		upgrade_card_visual._set_card_desc(card)
