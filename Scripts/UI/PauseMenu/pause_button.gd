class_name PauseButton extends Button

@export var pause_tex : Texture2D
@export var unpause_tex : Texture2D

@export var pause_menu_prefab : PackedScene
var pause_menu : Node

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	icon = unpause_tex if get_tree().paused else pause_tex

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_close_dialog"):
		_pressed()

func _pressed() -> void:
	if not get_tree().paused:
		if pause_menu_prefab.can_instantiate():
			pause_menu = pause_menu_prefab.instantiate()
			var current_scene_root := get_tree().current_scene
			current_scene_root.add_child(pause_menu)
			current_scene_root.move_child(pause_menu, get_parent().get_child_count() - 1)
			pause_menu.set_z_index(1)
	else:
		if is_instance_valid(pause_menu):
			pause_menu.queue_free()
			pause_menu = null
	get_tree().paused = !get_tree().paused
