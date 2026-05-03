shader_type spatial;
render_mode unshaded, shadows_disabled, cull_back;

uniform sampler2D tex_palette : source_color, filter_nearest;

// 0.0 = rojo
// 0.25 = negro
// 0.5 = verde
instance uniform float palette_offset = 0.0;

instance uniform bool highlighted = false;

void fragment() {

	vec2 palette_uv = UV + vec2(palette_offset, 0.0);

	vec3 color_base = texture(tex_palette, palette_uv).rgb;

	float t = fract(TIME * 0.5);
	float pulse = t * (1.0 - t) * 4.0;

	if (!highlighted) {
		pulse = 0.0;
	}

	vec3 final_color = mix(color_base, vec3(1.0), pulse * 0.4);

	ALBEDO = final_color;
}