shader_type spatial; // O spatial si no quieres que rote
render_mode unshaded, shadows_disabled, cull_back;
uniform sampler2D viewport_tex;
uniform bool is_left_side = true;

void fragment() {
    vec2 uv = UV;
    // Escalamos la X a la mitad
    uv.x = uv.x * 0.5;
    
    // Si es el lado derecho, le sumamos 0.5 al offset
    if (!is_left_side) {
        uv.x += 0.5;
    }
    
    ALBEDO = texture(viewport_tex, uv).rgb;
}