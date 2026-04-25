shader_type canvas_item;
render_mode blend_mix, unshaded;

// ── Parámetros ──────────────────────────────────────────────────────────────
uniform float intensity : hint_range(0.0, 1.0, 0.001) = 0.15;
uniform int   samples   : hint_range(1, 32, 1)        = 8;

// Velocidad de la cámara en espacio UV, seteada desde GDScript cada frame.
// x = horizontal, y = vertical  (valores típicos: -0.05 a 0.05)
uniform vec2  camera_velocity = vec2(0.0, 0.0);

// Textura de pantalla (Godot 4 Compatibility)
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// ── Main ─────────────────────────────────────────────────────────────────────
void fragment() {
	vec2 uv        = SCREEN_UV;
	vec2 blur_dir  = camera_velocity * intensity;

	vec4 color_accum = vec4(0.0);

	for (int i = 0; i < samples; i++) {
		// t ∈ [-0.5, 0.5] centrado en el píxel actual
		float t          = float(i) / float(samples - 1) - 0.5;
		vec2  sample_uv  = uv + blur_dir * t;
		sample_uv        = clamp(sample_uv, vec2(0.0), vec2(1.0));
		color_accum     += texture(SCREEN_TEXTURE, sample_uv);
	}

	COLOR = color_accum / float(samples);
}
