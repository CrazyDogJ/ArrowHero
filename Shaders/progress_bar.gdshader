shader_type canvas_item;
render_mode unshaded;

// 剩余进度：0.0 ～ 1.0
instance uniform float progress : hint_range(0.0, 1.0) = 1.0;

// 低、中、高进度对应的颜色
uniform vec4 low_color : source_color = vec4(0.95, 0.15, 0.15, 1.0);
uniform vec4 mid_color : source_color = vec4(1.0, 0.8, 0.1, 1.0);
uniform vec4 high_color : source_color = vec4(0.2, 0.85, 0.35, 1.0);

// 空余区域颜色；将 Alpha 设为 0 可隐藏背景
uniform vec4 background_color : source_color = vec4(0.12, 0.12, 0.15, 1.0);

void fragment() {
    float p = clamp(progress, 0.0, 1.0);

    // 中心为 0，左右两端为 1
    float distance_from_center = abs(UV.x - 0.5) * 2.0;

    // 边缘抗锯齿
    float edge_width = max(fwidth(distance_from_center), 0.0001);
    float fill = 1.0 - smoothstep(
        p - edge_width,
        p + edge_width,
        distance_from_center
    );

    // 确保 0% 完全清空，100% 完全填满
    if (p <= 0.0) {
        fill = 0.0;
    } else if (p >= 1.0) {
        fill = 1.0;
    }

    // 根据剩余进度为整个填充区域着色
    vec4 bar_color;
    if (p < 0.5) {
        bar_color = mix(low_color, mid_color, p * 2.0);
    } else {
        bar_color = mix(mid_color, high_color, (p - 0.5) * 2.0);
    }

    COLOR = mix(background_color, bar_color, fill);
}