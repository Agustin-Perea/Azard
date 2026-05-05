shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;

uniform vec4 color_aura : source_color = vec4(0.2, 0.5, 1.0, 1.0);
uniform float radio_base : hint_range(0.1, 0.4) = 0.25;
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
    return mix(mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void fragment() {
    vec2 uv = UV - 0.5;
    float dist = length(uv);
    float angulo = atan(uv.y, uv.x);

    // Creamos coordenadas que giran para el ruido
    // Usamos senos y cosenos del ángulo para que el ruido sea continuo (sin cortes)
    vec2 coordenadas_ruido = vec2(cos(angulo), sin(angulo)) * 1.5;
    
    // Capa de ruido 1: Movimiento principal
    float n1 = noise(coordenadas_ruido + TIME * velocidad_giro * 0.5);
    
    // Capa de ruido 2: Detalle más rápido (lava burbujeante)
    float n2 = noise(coordenadas_ruido * 2.0 - TIME * velocidad_giro);
    
    // Mezclamos ambos ruidos para la deformación
    float deformacion = (n1 + n2 * 0.5) * intensidad_lava;
    
    float limite = radio_base + deformacion;
    
    // Dibujamos el círculo
    float circulo = smoothstep(limite, limite - suavizado, dist);
    
    // Máscara de seguridad para no cortar contra el borde del Quad
    float mascara_quad = smoothstep(0.5, 0.4, dist);
    
    ALBEDO = color_aura.rgb;
    ALPHA = circulo * mascara_quad * color_aura.a;
}
