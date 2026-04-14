shader_type spatial;
render_mode unshaded, shadows_disabled, cull_back;

uniform sampler2D tex_palette : source_color, filter_nearest;

// x: offset_r, y: highlight_bool (0 o 1), z: thickness (para el outline)
instance uniform vec3 chip_data = vec3(0.0, 0.0, 0.0);

varying float final_offset_r;
varying float is_highlighted;

void vertex() {
	// Lógica para detectar si es MultiMesh o MeshInstance normal
	if (COLOR.r < 0.6) {
		// MultiMesh
		final_offset_r = COLOR.r;
		is_highlighted = COLOR.g;
	} else {
		// MeshInstance normal
		final_offset_r = 0.0;
		is_highlighted = 0.0;
	}
}

void fragment() {
	vec2 offset = vec2(final_offset_r, 0.0);

	// Color base desde la paleta
	vec3 color_base = texture(tex_palette, UV + offset).rgb;

	// Pulso estable (sin sin)
	float t = fract(TIME * 0.5);
	float pulse = t * (1.0 - t) * 4.0;
	pulse = clamp(pulse, 0.0, 1.0);

	// ✅ FIX: convertir highlight a 0 o 1 real (evita bugs en mobile)
	float highlight_flag = (is_highlighted > 0.5) ? 1.0 : 0.0;

	// Aplicar pulso solo si está highlighted
	pulse *= highlight_flag;

	// Mezcla final (controlada)
	vec3 final_color = mix(color_base, vec3(1.0), pulse * 0.4);

	ALBEDO = final_color;
}