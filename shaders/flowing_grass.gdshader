shader_type canvas_item;
uniform sampler2D noise: repeat_enable, filter_nearest;
varying vec2 world_position;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

vec4 overlay(vec4 base, vec4 blend){
    vec4 limit = step(0.5, base);
    return mix(
        2.0 * base * blend,
        1.0 - 2.0 * (1.0 - base) * (1.0 - blend),
        limit
    );
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	float t = TIME / 5000.0;
	
	vec2 size = vec2(textureSize(noise, 0));
	vec2 uv = (floor(world_position) + 0.5) / size;
	vec4 mask = texture(noise, uv);

	float n = texture(noise, uv + floor(t)).r;
	float wave = sin(TIME * 2.0 + world_position.x * 0.05);
	float highlight = step(0.8 + wave * 0.05, n);

	float r = hash(floor(world_position) + floor(t));

	vec2 offset = vec2(0.0, 0.0);
	if (r < 0.25) {
		offset = vec2(1.0, 0.0);
	} else if (r < 0.5) {
		offset = vec2(-1.0, 0.0);
	} else if (r < 0.75) {
		offset = vec2(0.0, 1.0);
	} else {
		offset = vec2(0.0, -1.0);
	}

	if (highlight >= 1.0) {
		vec2 pixel_uv = UV + offset / vec2(textureSize(TEXTURE, 0));
		COLOR = texture(TEXTURE, pixel_uv);
	}
}
