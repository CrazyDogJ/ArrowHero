extends Node

const SAVE_PATH := "user://settings.cfg"
const SECTION := "keybindings"

var ACTIONS := {
	"Up": tr("Up"),
	"Down": tr("Down"),
	"Left": tr("Left"),
	"Right": tr("Right"),
}

var _config := ConfigFile.new()

func _ready() -> void:
	var error := _config.load(SAVE_PATH)

	# 首次运行没有配置文件，直接使用项目默认键位。
	if error == ERR_FILE_NOT_FOUND:
		return

	if error != OK:
		push_warning("Load input settings failed：%s" % error_string(error))
		return

	for action in ACTIONS:
		if not InputMap.has_action(action):
			continue

		var code: Variant = _config.get_value(SECTION, action, 0)
		if code is int and code > 0:
			_apply_key(action, code)


# 替换该动作的所有键盘绑定，保留鼠标、手柄绑定。
func _apply_key(action: String, code: int) -> void:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			InputMap.action_erase_event(action, event)

	var key := InputEventKey.new()
	key.physical_keycode = code as Key
	InputMap.action_add_event(action, key)


func rebind(action: String, code: int) -> Error:
	if not ACTIONS.has(action) or not InputMap.has_action(action):
		return ERR_INVALID_PARAMETER

	if code <= 0:
		return ERR_INVALID_PARAMETER

	_apply_key(action, code)
	_config.set_value(SECTION, action, code)
	return _config.save(SAVE_PATH)


func get_binding_text(action: String) -> String:
	var names := PackedStringArray()

	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			names.append(event.as_text())

	if names.is_empty():
		return tr("unbind")

	return " / ".join(names)


func reset_defaults() -> Error:
	for action in ACTIONS:
		if not InputMap.has_action(action):
			continue

		# 从项目设置读取原始默认值，
		# 避免把用户修改后的 InputMap 当成默认值。
		var defaults: Dictionary = ProjectSettings.get_setting(
			"input/" + action, {}
		)

		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				InputMap.action_erase_event(action, event)

		for event in defaults.get("events", []):
			if event is InputEventKey:
				InputMap.action_add_event(action, event.duplicate())

	if _config.has_section(SECTION):
		_config.erase_section(SECTION)

	return _config.save(SAVE_PATH)
