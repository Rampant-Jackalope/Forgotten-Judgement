shader_type spatial;
render_mode unshaded, cull_back, depth_test_disabled, depth_draw_never, shadows_disabled;

global uniform vec4 highlight_color;

instance uniform bool enabled = false;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

uniform float visible_fill : hint_range(0.0, 1.0, 0.001) = 0.01;  // subtle tint when in plain view
uniform float hidden_fill : hint_range(0.0, 1.0, 0.01) = 0.45;   // stronger when behind something
uniform float stripe_size : hint_range(2.0, 40.0, 0.5) = 2.0;
uniform float stripe_strength : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float stripe_scroll : hint_range(0.0, 5.0, 0.1) = 0.0;
uniform float sweep_speed : hint_range(0.0, 5.0, 0.1) = 1.0;
uniform float sweep_strength : hint_range(0.0, 1.0, 0.01) = 0.05;
uniform float pulse_amount : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float glow : hint_range(1.0, 5.0, 0.1) = 1.0;
uniform float bias : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float bias_per_meter : hint_range(0.0, 0.1, 0.001) = 0.02;

void fragment() {
	if (!enabled) {
		discard;
	}

	// Hidden test: is something clearly in front of this pixel?
	float depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 v = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	v.xyz /= v.w;
	float frag_dist = -VERTEX.z;
	float tolerance = bias + frag_dist * bias_per_meter;
	float hidden = step(tolerance, frag_dist - (-v.z));

	// Screen-space diagonal stripes
	float s = fract((FRAGCOORD.x + FRAGCOORD.y) / stripe_size + TIME * stripe_scroll);
	float stripes = mix(1.0, step(0.5, s), stripe_strength);

	// Band travelling up the mesh in world space
	vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float sweep = pow(max(0.0, sin(world_pos.y * 3.0 - TIME * sweep_speed * 3.0)), 8.0) * sweep_strength;

	float pulse = 1.0 - pulse_amount + pulse_amount * (0.5 + 0.5 * sin(TIME * 3.0));

	float base = mix(visible_fill, hidden_fill * stripes, hidden);
	float a = clamp((base + sweep) * pulse, 0.0, 1.0);

	ALBEDO = highlight_color.rgb * glow;
	ALPHA = a * highlight_color.a;
}
