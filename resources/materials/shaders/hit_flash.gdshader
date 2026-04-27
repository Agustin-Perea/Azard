shader_type spatial;
// unshaded: no le afectan las luces
// cull_back: no dibuja las caras internas (estándar)
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;

uniform vec3 flash_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	ALBEDO = flash_color;
	ALPHA = flash_modifier;
}