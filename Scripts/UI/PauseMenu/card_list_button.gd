class_name CardListButton extends Button

@export var card_list_scene : PackedScene
var card_list_widget : UpgradeCardList

func _pressed() -> void:
	if card_list_scene.can_instantiate():
		card_list_widget = card_list_scene.instantiate()
		if is_instance_valid(card_list_widget) and is_instance_valid(GlobalVars.cards_manager):
			card_list_widget.upgrade_cards = GlobalVars.cards_manager.get_cards()
		var current_scene_root := get_tree().current_scene
		if is_instance_valid(current_scene_root):
			current_scene_root.add_child(card_list_widget)
			card_list_widget.set_z_index(2)

func _exit_tree() -> void:
	if is_instance_valid(card_list_widget):
		card_list_widget.queue_free()
	card_list_widget = null
