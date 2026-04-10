shader_type canvas_item;

uniform sampler2D mask_texture : filter_nearest;
uniform sampler2D palette_texture : filter_nearest, source_color;
uniform int palette_width;

void fragment() {
	float alpha = texture(mask_texture, UV).a;
	if (alpha < 0.01) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		float mask = texture(mask_texture, UV).r;
		int idx = int(floor(mask * float(palette_width - 1) + 0.5));
		float normal_idx = (float(idx) + 0.5) / float(palette_width);
		vec3 color = texture(palette_texture, vec2(normal_idx, 0.5)).rgb;
		COLOR = vec4(color, 1.0);
	}
}
