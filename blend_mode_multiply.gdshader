shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_enable;

vec4 multiply(vec4 base, vec4 blend){
	return base * blend;
}

void fragment() {
    vec4 base = texture(SCREEN_TEXTURE, SCREEN_UV);

    vec4 tex = texture(TEXTURE, UV);

    vec4 blend = tex * COLOR;

    vec4 multiplied = multiply(base, blend);

    float mask = tex.a;

    vec3 final_rgb = mix(base.rgb, multiplied.rgb, mask);

    COLOR = vec4(final_rgb, 1.0);
}
