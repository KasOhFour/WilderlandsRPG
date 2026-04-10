shader_type canvas_item;

uniform float blur_size : hint_range(0.0, 20.0) = 4.0;
uniform int samples : hint_range(1, 10) = 5;
uniform vec2 direction = vec2(1.0, 0.0); // horizontal

void fragment() {
    vec4 color = vec4(0.0);
    float total_weight = 0.0;

    for (int i = -samples; i <= samples; i++) {
        float offset = float(i) * blur_size;
        float weight = exp(-float(i*i) / float(samples*samples));
        color += texture(TEXTURE, UV + direction * offset / TEXTURE_PIXEL_SIZE) * weight;
        total_weight += weight;
    }

    COLOR = color / total_weight;
}
