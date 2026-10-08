class_name UpgradeCardList extends Node

@export var upgrade_cards : Array[UpgradeCard]
@export var upgrade_card_prefab : PackedScene
@export var list_container : Container

func _ready() -> void:
	if is_instance_valid(list_container) and is_instance_valid(upgrade_card_prefab) and upgrade_card_prefab.can_instantiate():
		for card in upgrade_cards:
			var new_card_visual : UpgradeCardVisual = upgrade_card_prefab.instantiate()
			if is_instance_valid(new_card_visual):
				new_card_visual.card_desc = card
				list_container.add_child(new_card_visual)
