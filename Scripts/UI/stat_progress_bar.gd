@tool
class_name StatProgressBar
extends ProgressBar

## 支持 {value}、{max_value}、{min_value}、{percent}。
@export var text_format: String = "{value} / {max_value}":
	set(new_format):
		text_format = new_format
		refresh_text()

## 数值显示的小数位数，不影响实际 value。
@export_range(0, 6, 1) var decimal_places: int = 0:
	set(new_places):
		decimal_places = new_places
		refresh_text()

@onready var _value_label: Label = $ValueLabel

@export var fill_color : Color = Color("ff0000")

func _ready() -> void:
	show_percentage = false

	var sb = StyleBoxFlat.new()
	add_theme_stylebox_override("fill", sb)
	sb.set_corner_radius_all(8)
	sb.bg_color = fill_color
	
	_value_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 避免长文本撑大控件。
	_value_label.clip_text = true

	if not value_changed.is_connected(_on_value_changed):
		value_changed.connect(_on_value_changed)

	# 最大值、最小值等变化时，也需要刷新文本。
	if not changed.is_connected(refresh_text):
		changed.connect(refresh_text)

	refresh_text()


func _on_value_changed(_new_value: float) -> void:
	refresh_text()


func refresh_text() -> void:
	# 导出属性的 setter 可能早于 _ready() 执行。
	if not is_instance_valid(_value_label):
		return

	_value_label.text = text_format.format({
		"value": _format_number(value),
		"max_value": _format_number(max_value),
		"min_value": _format_number(min_value),
		"percent": _format_number(ratio * 100.0),
	})


func _format_number(number: float) -> String:
	return ("%." + str(decimal_places) + "f") % number
