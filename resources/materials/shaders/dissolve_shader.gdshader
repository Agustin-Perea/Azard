shader_type spatial;

render_mode unshaded, shadows_disabled, cull_disabled;

// === BASE ===
uniform vec4 base_color : source_color = vec4(1.0);
uniform sampler2D main_texture : source_color;
uniform sampler2D noise_tex;

// === DISSOLVE ===
uniform float dissolve_value : hint_range(0.0, 1.0) = 0.0;
uniform vec4 burn_color : source_color = vec4(1.0, 0.3, 0.0, 1.0);
uniform float burn_size : hint_range(0.0, 0.1) = 0.04;

// === FLASH ===
uniform vec3 flash_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;

varying vec3 local_pos;

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	// =====================
	// NOISE / DISSOLVE
	// =====================
	vec2 custom_uv = local_pos.xy * 0.5;
	float noise_sample = texture(noise_tex, custom_uv).r;

	if (noise_sample < dissolve_value) {
		discard;
	}

	// =====================
	// BASE COLOR
	// =====================
	vec4 tex_color = texture(main_texture, UV) * base_color;
	vec3 final_color;

	float stop_burn = dissolve_value + burn_size;

	if (noise_sample < stop_burn) {
		final_color = burn_color.rgb;
		EMISSION = burn_color.rgb * 3.0;
	} else {
		final_color = tex_color.rgb;
	}

	// =====================
	// FLASH (BLEND A BLANCO)
	// =====================
	final_color = mix(final_color, flash_color, flash_modifier);

	// opcional: que también brille más cuando flashea
	EMISSION += flash_color * flash_modifier * 2.0;

	ALBEDO = final_color;
}