class_name DamageNumber extends Node2D

@export var jump_speed: float = 180.0       # 向上抛出的速度
@export var gravity: float = 520.0          # 下落加速度
@export var horizontal_speed: float = 65.0 # 左右散开的最大速度
@export var lifetime: float = 0.9           # 总显示时间
@export var fade_duration: float = 0.3      # 最后多久开始淡出

@export var icon_size: float = 32

@export var label: Label
@export var icon_texture_rect: TextureRect

var _velocity := Vector2.ZERO
var _elapsed: float = 0.0
var _active: bool = false


func _ready() -> void:
	z_index = 100
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE


# 先 add_child()，再调用这个方法。
func setup(amount: int, tex : Texture2D = null, in_color : Color = Color.WHITE, in_size : int = 24) -> void:
	label.text = str(amount)

	if is_instance_valid(icon_texture_rect):
		icon_texture_rect.texture = tex
		icon_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_texture_rect.size = Vector2(icon_size, icon_size)

	# 每个数字使用独立样式，避免暴击颜色影响其他数字。
	var settings := LabelSettings.new()
	settings.font_size = in_size
	settings.font_color = in_color
	settings.outline_size = 4
	settings.outline_color = Color("#202020")
	label.label_settings = settings

	# 让数字以根节点位置为中心。
	label.reset_size()

	_velocity = Vector2(
		RandomGenerator.get_rng_safe("physics").randf_range(-horizontal_speed, horizontal_speed),
		-jump_speed
	)
	_elapsed = 0.0
	modulate.a = 1.0
	_active = true

	# 出现时先放大，再回到正常大小。
	scale = Vector2.ONE * 0.65
	var peak_scale: float = 1.15
	var tween := create_tween()
	tween.tween_property(
		self, "scale", Vector2.ONE * peak_scale, 0.08
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		self, "scale", Vector2.ONE, 0.12
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)


func _process(delta: float) -> void:
	if not _active:
		return

	_elapsed += delta

	# Godot 的 Y 轴向下为正：负速度上升，重力使速度逐渐转正。
	position += _velocity * delta + Vector2(
		0.0, 0.5 * gravity * delta * delta
	)
	_velocity.y += gravity * delta

	# 在生命周期末尾淡出。
	var fade_time := clampf(fade_duration, 0.0, lifetime)
	if fade_time > 0.0:
		modulate.a = clampf(
			(lifetime - _elapsed) / fade_time, 0.0, 1.0
		)

	if _elapsed >= lifetime:
		queue_free()
