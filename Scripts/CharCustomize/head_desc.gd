class_name HeadDesc extends Node

@export_category("Sprite Setup")
@export var eye_l_sprite : Sprite2D
@export var eye_r_sprite : Sprite2D
@export var mouth_sprite : Sprite2D

@export_category("Sprite Textures")
@export var eye_l_texture : Texture2D
@export var eye_r_texture : Texture2D
@export var eye_l_close_texture : Texture2D
@export var eye_r_close_texture : Texture2D
@export var mouth_idle_texture : Texture2D
@export var mouth_open_texture : Texture2D

@export_category("Expression Setup")
@export var blink_wait_random_range : Vector2 = Vector2(1.5, 3)
@export var blink_random_range : Vector2 = Vector2(0.2, 0.5)
@export var speaking_mouth_time : float = 0.5

@export_category("State")
@export var is_blinking : bool = true:
	set(value):
		is_blinking = value
		is_eye_closed = false
		if not value:
			if is_instance_valid(eye_r_sprite):
				eye_r_sprite.texture = eye_r_texture
			if is_instance_valid(eye_l_sprite):
				eye_l_sprite.texture = eye_l_texture
		else:
			current_blink_wait = 0
			current_blink = 0
			start_blink_wait()
var blink_wait_target : float = 2
var blink_target : float = 0.3
var is_eye_closed : bool = false
var current_blink_wait : float = 0
var current_blink : float = 0

@export var is_speaking : bool = false:
	set(value):
		is_speaking = value
		if is_instance_valid(mouth_sprite):
			if not value:
				mouth_sprite.texture = mouth_idle_texture
			else:
				current_speak_time = 0
var is_mouth_closed : bool = true
var current_speak_time : float = 0

func start_blink_wait() -> void:
	if is_instance_valid(eye_r_sprite):
		eye_r_sprite.texture = eye_r_texture
	if is_instance_valid(eye_l_sprite):
		eye_l_sprite.texture = eye_l_texture
	blink_wait_target = randf_range(blink_wait_random_range.x, blink_wait_random_range.y)
	current_blink_wait = 0

func start_blink() -> void:
	if is_instance_valid(eye_r_sprite):
		eye_r_sprite.texture = eye_r_close_texture
	if is_instance_valid(eye_l_sprite):
		eye_l_sprite.texture = eye_l_close_texture
	blink_target = randf_range(blink_random_range.x, blink_random_range.y)
	current_blink = 0

func update_blink(delta: float) -> void:
	if not is_blinking:
		return
	if is_eye_closed:
		current_blink += delta
		if current_blink >= blink_target:
			is_eye_closed = false
			start_blink_wait()
	else:
		current_blink_wait += delta
		if current_blink_wait >= blink_wait_target:
			is_eye_closed = true
			start_blink()

func update_speaking(delta: float) -> void:
	if not is_speaking:
		return
	current_speak_time += delta
	if current_speak_time >= speaking_mouth_time:
		current_speak_time = 0
		is_mouth_closed = not is_mouth_closed
		update_speaking_sprite()

func update_speaking_sprite() -> void:
	if is_instance_valid(mouth_sprite):
		mouth_sprite.texture = mouth_idle_texture if is_mouth_closed else mouth_open_texture

func _ready() -> void:
	if is_blinking:
		start_blink_wait()
	update_speaking_sprite()

func _process(delta: float) -> void:
	update_blink(delta)
	update_speaking(delta)
