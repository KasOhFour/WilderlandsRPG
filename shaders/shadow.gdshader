shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0) = 0.33;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
	vec4 screen = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec3 gray = vec3(1.0 - strength);
	vec3 blended = screen.rgb * (tex.a * gray + (1.0 - tex.a));
    COLOR = vec4(blended, tex.a);
}