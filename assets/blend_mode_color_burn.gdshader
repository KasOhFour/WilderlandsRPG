shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

vec4 color_burn(vec4 base, vec4 blend) {
	return clamp(
		1.0 - (1.0 - base) / max(blend, vec4(0.0001)),
		0.0,
		1.0
	);
}

void fragment() {
	vec4 base = texture(SCREEN_TEXTURE, SCREEN_UV);

	vec4 tex = texture(TEXTURE, UV);
	vec4 blend = tex * COLOR;

	vec4 burned = color_burn(base, blend);

	float mask = tex.a;

	vec3 final_rgb = mix(base.rgb, burned.rgb, mask);

	COLOR = vec4(final_rgb, 1.0);
}
