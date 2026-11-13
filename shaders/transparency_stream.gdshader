shader_type canvas_item;

uniform vec3 key_color : source_color = vec3(0.0, 1.0, 0.0);
uniform float threshold = 0.3;
uniform float softness = 0.1;

void fragment() {
    vec4 c = texture(TEXTURE, UV);
    float d = distance(c.rgb, key_color);
    c.a = smoothstep(threshold, threshold + softness, d);
    COLOR = c;
}
