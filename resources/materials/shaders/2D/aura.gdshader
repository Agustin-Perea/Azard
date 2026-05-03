shader_type spatial;
render_mode unshaded, blend_add, depth_draw_opaque, cull_disabled;

uniform vec4 color_aura : source_color = vec4(0.1, 0.4, 1.0, 1.0);
uniform float radio_anillo : hint_range(0.0, 0.5) = 0.25; // Controla la distancia al centro
uniform float velocidad : hint_range(0.1, 5.0) = 1.2;
uniform float cantidad_ondas : hint_range(1.0, 10.0) = 2.0;
uniform float intensidad_deform : hint_range(0.0, 0.2) = 0.05;
uniform float smoothing : hint_range(0.01, 0.2) = 0.08;

void fragment() {
    // 1. Coordenadas centradas
    vec2 uv = UV - 0.5;
    float dist = length(uv);
    float angulo = atan(uv.y, uv.x);

    // 2. Deformación armónica ultra ligera
    float deform = sin(angulo * 3.0 + TIME * velocidad) * 0.5;
    deform += cos(angulo * 5.0 - TIME * velocidad * 0.7) * 0.3;
    deform *= intensidad_deform;

    // 3. Aplicar el radio y la deformación
    // Restamos el radio_anillo para desplazar el "cero" de la onda
    float d_mod = (dist - radio_anillo) + deform;
    
    // 4. Ondas expansivas controladas
    float onda = fract(d_mod * cantidad_ondas - TIME * velocidad);
    
    // 5. Suavizado (Smoothing)
    float anillo = smoothstep(0.0, smoothing, onda) * smoothstep(smoothing * 2.0, smoothing, onda);
    
    // 6. Máscaras de seguridad para evitar cortes en el borde del Quad
    // El 0.48 asegura que nunca veamos el borde cuadrado de la malla
    float mascara_borde = smoothstep(0.48, 0.48 - smoothing, dist);
    
    // Opcional: Desvanecer también hacia el centro absoluto
    float mascara_centro = smoothstep(0.0, smoothing, dist);

    ALBEDO = color_aura.rgb;
    ALPHA = anillo * mascara_borde * mascara_centro * color_aura.a;
}