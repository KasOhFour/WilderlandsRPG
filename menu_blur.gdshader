shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Pixel-art-friendly parameters
uniform int lod_level : hint_range(0, 10) = 2;       // Base LOD blur
uniform float brightness : hint_range(0.0, 3.0) = 1.0; // Brightness multiplier
uniform float distortion_intensity : hint_range(0.0, 0.05) = 0.0; // optional small UV offset

// Bicubic helper functions
float w0(float a) { return (1.0 / 6.0) * (a * (a * (-a + 3.0) - 3.0) + 1.0); }
float w1(float a) { return (1.0 / 6.0) * (a * a * (3.0 * a - 6.0) + 4.0); }
float w2(float a) { return (1.0 / 6.0) * (a * (a * (-3.0 * a + 3.0) + 3.0) + 1.0); }
float w3(float a) { return (1.0 / 6.0) * (a * a * a); }
float g0(float a) { return w0(a) + w1(a); }
float g1(float a) { return w2(a) + w3(a); }
float h0(float a) { return -1.0 + w1(a) / (w0(a) + w1(a)); }
float h1(float a) { return 1.0 + w3(a) / (w2(a) + w3(a)); }

vec4 texture2D_bicubic(sampler2D tex, vec2 uv, int p_lod, ivec2 tex_size) {
    vec2 tex_size_lod = vec2(tex_size >> p_lod);
    vec2 pixel_size = 1.0 / tex_size_lod;
    uv = uv * tex_size_lod + 0.5;
    vec2 iuv = floor(uv);
    vec2 fuv = fract(uv);
    float g0x = g0(fuv.x);
    float g1x = g1(fuv.x);
    float h0x = h0(fuv.x);
    float h1x = h1(fuv.x);
    float h0y = h0(fuv.y);
    float h1y = h1(fuv.y);
    vec2 p0 = (vec2(iuv.x + h0x, iuv.y + h0y) - 0.5) * pixel_size;
    vec2 p1 = (vec2(iuv.x + h1x, iuv.y + h0y) - 0.5) * pixel_size;
    vec2 p2 = (vec2(iuv.x + h0x, iuv.y + h1y) - 0.5) * pixel_size;
    vec2 p3 = (vec2(iuv.x + h1x, iuv.y + h1y) - 0.5) * pixel_size;
    return (g0(fuv.y) * (g0x * textureLod(tex, p0, float(p_lod)) + g1x * textureLod(tex, p1, float(p_lod)))) +
           (g1(fuv.y) * (g0x * textureLod(tex, p2, float(p_lod)) + g1x * textureLod(tex, p3, float(p_lod))));
}

void fragment() {
    vec2 uv = SCREEN_UV;

    // Optional simple distortion
    vec2 distorted_uv = uv; 
    if (distortion_intensity > 0.0) {
        float n = fract(sin(dot(UV * 1234.0, vec2(12.9898,78.233))) * 43758.5453);
        distorted_uv += (n - 0.5) * distortion_intensity;
    }

    // Sample blurred screen
    vec4 blurred = texture2D_bicubic(SCREEN_TEXTURE, distorted_uv, lod_level, textureSize(SCREEN_TEXTURE,0));

    // Apply brightness
    blurred.rgb *= brightness;

    // Mix with node’s modulate color (self_modulate)
    COLOR.rgb = mix(blurred.rgb, COLOR.rgb, COLOR.a);
    COLOR.a = COLOR.a;
}
