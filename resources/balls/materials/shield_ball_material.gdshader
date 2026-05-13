shader_type spatial;

render_mode blend_mix, cull_front, unshaded;

// PNG/icono
uniform sampler2D icon_texture : source_color;

// Color de esfera
uniform vec4 sphere_color : source_color =
	vec4(0.2, 0.8, 1.0, 0.12);

// Color del icono
uniform vec4 icon_color : source_color =
	vec4(1.0, 1.0, 1.0, 1.0);

uniform float icon_scale = 1.2;

uniform float fresnel_power = 4.0;
uniform float fresnel_strength = 1.5;

varying vec3 local_pos;

void vertex() {
	local_pos = VERTEX;
}

void fragment() {

	// =========================
	// FRESNEL
	// =========================

	float fresnel = pow(
		1.0 - dot(normalize(NORMAL), normalize(VIEW)),
		fresnel_power
	);

	vec3 fresnel_color =
		sphere_color.rgb *
		fresnel *
		fresnel_strength;

	// =========================
	// ICONO INTERNO
	// =========================

	vec2 uv =
		local_pos.xy * icon_scale +
		vec2(0.5);

	vec4 icon =
		texture(icon_texture, uv);

	vec3 icon_glow =
		icon.rgb *
		icon.a *
		icon_color.rgb *
		3.0;

	// =========================
	// RESULTADO
	// =========================

	ALBEDO =
		sphere_color.rgb +
		fresnel_color * 0.5;

	EMISSION =
		fresnel_color +
		icon_glow;

	ALPHA =
		sphere_color.a +
		(fresnel * 0.2);
}