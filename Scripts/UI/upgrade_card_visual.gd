class_name UpgradeCardVisual extends Node

@export var card_desc : UpgradeCard

@export var card_name_label : Label
@export var card_desc_label : Label
@export var card_icon_rect : TextureRect

func update_visual() -> void:
	if is_instance_valid(card_desc):
		if is_instance_valid(card_name_label):
			card_name_label.text = tr(card_desc.card_name)
		if is_instance_valid(card_desc_label):
			var translated_string = tr(card_desc.card_desc)
			card_desc_label.text = card_desc.make_text(translated_string)
		if is_instance_valid(card_icon_rect):
			card_icon_rect.texture = card_desc.card_icon

func _ready() -> void:
	update_visual()

func _set_card_desc(in_card : UpgradeCard) -> void:
	card_desc = in_card
	update_visual()
