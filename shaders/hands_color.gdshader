shader_type canvas_item;

uniform float stamina_ratio : hint_range(0.0, 1.0) = 1.0;
uniform vec4 green_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float hand_threshold : hint_range(0.0, 1.0) = 0.8; // Top 80% represents the hands (0.0 = top, 1.0 = bottom)
uniform float is_damaged : hint_range(0.0, 1.0) = 0.0;
uniform vec4 damage_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Discard transparent pixels to avoid a solid background block
    if (tex_color.a <= 0.0) {
        discard;
    }
    
    vec4 final_color = tex_color;
    
    // Tint only the top 80% (hands) green based on stamina ratio while preserving texture details (shading and lines)
    if (UV.y <= hand_threshold) {
        vec3 green_tint = mix(vec3(1.0), green_color.rgb, stamina_ratio);
        final_color.rgb = tex_color.rgb * green_tint;
    } else {
        final_color.rgb = tex_color.rgb;
    }
    
    // Apply damage flash overlay (turns the sprite red when damaged)
    final_color.rgb = mix(final_color.rgb, damage_color.rgb, is_damaged);
    
    // Preserve the original texture alpha
    final_color.a = tex_color.a;
    
    COLOR = final_color;
}