class_name PauseButton extends Button

@export var pause_tex : Texture2D
@export var unpause_tex : Texture2D

@export var pause_menu_prefab : PackedScene
var pause_menu : Node

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	icon = unpause_tex if get_tree().paused else pause_tex

func _pressed() -> void:
	if not get_tree().paused:
		if pause_menu_prefab.can_instantiate():
			pause_menu = pause_menu_prefab.instantiate()
			get_tree().root.add_child(pause_menu)
	else:
		if is_instance_valid(pause_menu):
			pause_menu.queue_free()
			pause_menu = null
	get_tree().paused = !get_tree().paused
