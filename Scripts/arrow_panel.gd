extends PanelContainer

@export var background_color := Color("#2b2f3a")
@export var corner_radius := 12
@export var padding := Vector4(16, 10, 16, 10) # 左、上、右、下

func _ready() -> void:
	var style := StyleBoxFlat.new()

	style.bg_color = background_color
	style.set_corner_radius_all(corner_radius)

	style.content_margin_left = padding.x
	style.content_margin_top = padding.y
	style.content_margin_right = padding.z
	style.content_margin_bottom = padding.w

	add_theme_stylebox_override("panel", style)
