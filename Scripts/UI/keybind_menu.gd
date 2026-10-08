class_name KeyBindVBox extends VBoxContainer

var _waiting_action: String = ""
var _buttons: Dictionary = {}
var _hint: Label
var _reset_button: Button


func _ready() -> void:
	# 即使游戏暂停，设置菜单仍可接收输入。
	process_mode = Node.PROCESS_MODE_ALWAYS

	for action in InputSettings.ACTIONS:
		if not InputMap.has_action(action):
			push_warning("Action not in input mappings：%s" % action)
			continue

		var button := Button.new()
		# 本示例用鼠标点击按钮，避免回车/空格触发按钮时被误绑定。
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_begin_rebind.bind(action))
		add_child(button)
		_buttons[action] = button

	_reset_button = Button.new()
	_reset_button.text = tr("revert_default_key_binding")
	_reset_button.focus_mode = Control.FOCUS_NONE
	_reset_button.pressed.connect(_reset_defaults)
	add_child(_reset_button)

	_hint = Label.new()
	_hint.text = tr("click_action_and_rebind_key")
	add_child(_hint)

	visibility_changed.connect(_on_visibility_changed)
	_refresh_buttons()


func _begin_rebind(action: String) -> void:
	_waiting_action = action
	_hint.text = tr("bind_new_key_esc_quit")
	_refresh_buttons()


func _input(event: InputEvent) -> void:
	if _waiting_action.is_empty() or not is_visible_in_tree():
		return

	# 拦截本次事件，避免继续传给 GUI 和未处理输入回调。
	get_viewport().set_input_as_handled()

	if not event is InputEventKey:
		return

	var key := event as InputEventKey
	if not key.pressed or key.echo:
		return

	if key.keycode == KEY_ESCAPE:
		_waiting_action = ""
		_hint.text = tr("cancel_rebind")
		_refresh_buttons()
		return

	if key.physical_keycode == 0:
		return

	var error := InputSettings.rebind(
		_waiting_action,
		key.physical_keycode
	)

	_waiting_action = ""
	_show_save_result(error)
	_refresh_buttons()


func _reset_defaults() -> void:
	_waiting_action = ""
	_show_save_result(InputSettings.reset_defaults())
	_refresh_buttons()


func _show_save_result(error: Error) -> void:
	if error == OK:
		_hint.text = tr("input_settings_saved")
	else:
		_hint.text = tr("input_rebind_but_save_failed") + "：%s" % error_string(error)


func _refresh_buttons() -> void:
	var waiting := not _waiting_action.is_empty()

	for action in _buttons:
		var button: Button = _buttons[action]
		button.disabled = waiting

		var binding := InputSettings.get_binding_text(action)
		if action == _waiting_action:
			binding = tr("waiting_key_input")

		button.text = "%s：%s" % [
			InputSettings.ACTIONS[action],
			binding,
		]

	_reset_button.disabled = waiting


func _on_visibility_changed() -> void:
	if not is_visible_in_tree() and not _waiting_action.is_empty():
		_waiting_action = ""
		_hint.text = tr("cancel_rebind")
		_refresh_buttons()
