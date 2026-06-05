shader_type canvas_item; // Cambiado de spatial a canvas_item para 2D
render_mode blend_mix;   // Eliminados los modos de renderizado 3D

uniform vec4 color_aura : source_color = vec4(0.2, 0.5, 1.0, 1.0);

uniform float radio_base : hint_range(0.1, 0.4) = 0.25;
uniform float radio_interno : hint_range(0.0, 0.3) = 0.08;

uniform float velocidad_giro : hint_range(-10.0, 10.0) = 2.0;
uniform float intensidad_lava : hint_range(0.0, 0.3) = 0.1;
uniform float suavizado : hint_range(0.01, 0.1) = 0.03;

// Ruido simple y rápido
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(
        mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
        mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
        u.y
    );
}

void fragment() {
    vec2 uv = UV - 0.5;

    float dist = length(uv);
    float angulo = atan(uv.y, uv.x);

    // Coordenadas del ruido
    vec2 coordenadas_ruido = vec2(cos(angulo), sin(angulo)) * 1.5;

    // Ruido principal
    float n1 = noise(coordenadas_ruido + TIME * velocidad_giro * 0.5);

    // Ruido secundario
    float n2 = noise(coordenadas_ruido * 2.0 - TIME * velocidad_giro);

    // Deformación
    float deformacion = (n1 + n2 * 0.5) * intensidad_lava;

    float limite = radio_base + deformacion;

    // Exterior animado
    float circulo_externo = smoothstep(limite, limite - suavizado, dist);

    // Interior fijo/transparente
    float circulo_interno = smoothstep(radio_interno, radio_interno + suavizado, dist);

    // Aura final
    float aura = circulo_externo * circulo_interno;

    // Seguridad contra bordes del quad/textura
    float mascara_quad = smoothstep(0.5, 0.4, dist);

    // Multiplicamos por el color del nodo (por si quieres modularlo desde el editor)
    vec4 color_final = color_aura * COLOR; 

    // En 2D se usa COLOR en lugar de ALBEDO y ALPHA
    COLOR = vec4(color_final.rgb, aura * mascara_quad * color_final.a);
}