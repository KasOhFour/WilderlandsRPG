shader_type canvas_item;

uniform sampler2D mask : filter_nearest;
uniform sampler2D palette : filter_nearest, source_color;
uniform int palette_width;

void fragment() {
	float a = texture(mask, UV).a;
	if (a < 0.01) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		float m = texture(mask, UV).r;
		int i = int(floor(m * float(palette_width - 1) + 0.5));
		float normal = (float(i) + 0.5) / float(palette_width);
		vec3 color = texture(palette, vec2(normal, 0.5)).rgb;
		COLOR = vec4(color, 1.0);
	}
}
