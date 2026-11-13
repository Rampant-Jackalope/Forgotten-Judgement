shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;

global uniform vec4 highlight_color;

uniform sampler2D tex : source_color, filter_linear, repeat_disable;
uniform bool enabled = false;
uniform float outline_px : hint_range(0.0, 16.0, 0.5) = 3.0; // thickness in texels
uniform float pulse_amount : hint_range(0.0, 1.0, 0.01) = 0.3;
uniform float glow : hint_range(1.0, 5.0, 0.1) = 1.5;

varying vec2 pad_scale;

float sample_a(vec2 uv) {
	// treat everything outside the image as transparent
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		return 0.0;
	}
	return texture(tex, uv).a;
}

void vertex() {
	// Y-axis billboard
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		INV_VIEW_MATRIX[0],
		MODEL_MATRIX[1],
		vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, MODEL_MATRIX[1].xyz)), 0.0),
		MODEL_MATRIX[3]);

	// grow the quad so the outline isn't clipped, and remap UVs to match
	vec2 size = vec2(textureSize(tex, 0));
	float pad = enabled ? outline_px + 1.0 : 0.0;
	vec2 s = 1.0 + 2.0 * pad / size;
	VERTEX.xy *= s;
	UV = (UV - 0.5) * s + 0.5;
}

void fragment() {
	vec4 c = texture(tex, UV);

	if (!enabled) {
		if (c.a < 0.01) {
			discard;
		}
		ALBEDO = c.rgb;
		ALPHA = c.a;
	} else {
		float a = sample_a(UV);

		vec2 px = outline_px / vec2(textureSize(tex, 0));
		float n = 0.0;
		for (int i = 0; i < 8; i++) {
			float ang = float(i) * TAU / 8.0;
			n = max(n, sample_a(UV + vec2(cos(ang), sin(ang)) * px));
		}
		float outline = n * (1.0 - a);

		float pulse = 1.0 - pulse_amount + pulse_amount * (0.5 + 0.5 * sin(TIME * 3.0));
		vec3 line_col = highlight_color.rgb * glow;

		ALBEDO = mix(line_col, c.rgb, a);
		ALPHA = max(a, outline * pulse * highlight_color.a);

		if (ALPHA < 0.01) {
			discard;
		}
	}
}