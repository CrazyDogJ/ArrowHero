shader_type canvas_item;

uniform float sin_phase = 2.0;
uniform vec2 opacity_range = vec2(0.2, 1);

void fragment() {
	float phase = sin_phase * PI * TIME;
	float wave = abs(sin(phase));
	float wave_opacity = mix(opacity_range.x, opacity_range.y, wave);
	
	vec4 t = texture(TEXTURE, UV);
	COLOR = vec4(t.rgb, t.a * wave_opacity);
}