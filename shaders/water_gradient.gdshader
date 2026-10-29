shader_type canvas_item;

uniform sampler2D height_map : hint_default_black;
uniform vec2 map_size;        // map size in world units (pixels)
uniform float water_level = -0.10;
uniform float depth_range = 0.10;

varying vec2 world_pos;

void vertex() {
    // Convert local vertex position to world (canvas) space
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 base = texture(TEXTURE, UV);

    // Normalize world position into 0–1 UVs
    vec2 world_uv = world_pos / map_size;

    float height = texture(height_map, world_uv).r;

    float depth = clamp((water_level - height) / depth_range, 0.6, 1.0);
	depth = pow(depth, 1.1);

	vec3 shallow = vec3(0.94, 0.84, 0.59);
	vec3 deep = vec3(0.53, 0.53, 0.48);

	// Color blend
	vec3 color = mix(shallow, deep, depth);

	COLOR = vec4(color, 1.0);

    //float alpha = smoothstep(0.0, 1.0, depth);
	//float final_alpha = base.a * alpha;
//
    //COLOR = vec4(base.rgb * final_alpha, final_alpha);
}
