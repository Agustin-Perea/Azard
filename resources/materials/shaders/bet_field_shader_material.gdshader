shader_type spatial;
render_mode unshaded, shadows_disabled, cull_back;

uniform sampler2D tex_palette : source_color, filter_nearest;

// x: offset_r, y: highlight_bool (0 o 1), z: thickness (para el outline)
instance uniform vec3 chip_data = vec3(0.0, 0.0, 0.0);

varying float final_offset_r;
varying float is_highlighted;

void vertex() {
	// Lógica para detectar si es MultiMesh o MeshInstance normal
	if (COLOR.rgb == vec3(1.0)) {
		final_offset_r = chip_data.x;
		is_highlighted = chip_data.y; // Usamos el segundo valor del vec3
	} else {
		final_offset_r = COLOR.r;
		is_highlighted = COLOR.g; // En MultiMesh usamos el canal Verde
	}
}

void fragment() {
	vec2 offset = vec2(final_offset_r, 0.0);
	vec3 color_base = texture(tex_palette, UV + offset).rgb;
	
	// Animación de pulso: va de 0.0 a 1.0 suavemente
	// Multiplicamos por is_highlighted para que si es 0, el pulso sea siempre 0
	float pulse = (sin(TIME * 6.0) * 0.5 + 0.5) * is_highlighted;
	
	// Mezclamos el color base con Blanco Puro (vec3(1.0))
	// 0.0 = Color normal | 1.0 = Blanco total
	vec3 final_color = mix(color_base, vec3(1.0), pulse * 0.5); // 0.5 para que no sea tan cegador
	
	ALBEDO = final_color;
}