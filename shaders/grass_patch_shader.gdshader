shader_type canvas_item;
uniform vec4 tint_color : source_color = vec4(1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.33;

vec3 rgb_to_hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;

    return vec3(
        abs(q.z + (q.w - q.y) / (6.0 * d + e)),
        d / (q.x + e),
        q.x
    );
}

vec3 hsv_to_rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);

    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    vec3 base_hsv = rgb_to_hsv(tex.rgb);
    vec3 tint_hsv = rgb_to_hsv(tint_color.rgb);

    // Replace hue and saturation, preserve brightness
    vec3 result_hsv = vec3(
        tint_hsv.x,
        tint_hsv.y,
        base_hsv.z
    );

    vec3 color_blended = hsv_to_rgb(result_hsv);

    tex.rgb = mix(tex.rgb, color_blended, tint_strength);

    COLOR = tex;
}