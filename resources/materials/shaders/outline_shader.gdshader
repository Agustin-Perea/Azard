shader_type spatial;
render_mode unshaded, cull_front, blend_mix, depth_draw_opaque;

uniform bool active = true; // NUEVO: Interruptor
uniform float weight = 0.1;
uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec3 offset = vec3(0.2, 0.2, -0.1); 

void vertex() {
	if (active) {
		vec3 thickness = NORMAL * weight * COLOR.r;
		VERTEX += thickness + offset;
	} else {
		// Si no está activo, colapsamos los vértices para que no se renderice nada
		VERTEX = vec3(0.0);
	}
}

void fragment() {
	if (!active) {
		discard; // Descarta los píxeles por completo si no está activo
	}
	ALBEDO = color.rgb;
	ALPHA = color.a;
}