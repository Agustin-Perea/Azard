shader_type canvas_item;

// Color base que se usará como sólido, o se multiplicará por la textura
uniform vec4 albedo : source_color = vec4(1.0);

// ACTIVA ESTO EN EL INSPECTOR SI VAS A USAR UNA TEXTURA
uniform bool usar_textura = false; 
uniform sampler2D textura_esfera : hint_default_transparent;

// Parámetros de control
uniform float radio : hint_range(0.1, 1.0) = 1.0; // Controla el tamaño del círculo
uniform vec2 rotacion = vec2(0.0, 0.0);           // Para rotar la textura sobre la esfera

void fragment() {
    // 1. Centrar UV y normalizar a rango [-1, 1]
    vec2 p = (UV - 0.5) * 2.0;
    
    // 2. Calcular la distancia al centro tomando en cuenta el radio elegido
    float d = dot(p, p);
    float radio_cuadrado = radio * radio;
    
    // Si está fuera del radio configurado, recortamos el píxel para mantener la forma esférica externa
    if (d > radio_cuadrado) {
        discard;
    }

    vec4 color_final;

    if (!usar_textura) {
        // SI NO SE USA TEXTURA: Mostramos puramente el color albedo configurado
        color_final = albedo;
    } else {
        // SI SE USA TEXTURA: Calculamos la perspectiva 3D esférica
        
        // Re-normalizar los puntos dentro del nuevo radio para la curvatura
        vec2 p_normalizado = p / radio;
        float d_normalizado = dot(p_normalizado, p_normalizado);
        
        // Calcular la coordenada Z "virtual" de la superficie de la esfera
        float z = sqrt(1.0 - d_normalizado);
        vec3 normal = vec3(p_normalizado.x, p_normalizado.y, z);

        // Mapeo UV Esférico
        float pi = 3.1415926535;
        float u = atan(normal.x, normal.z) / (2.0 * pi) + 0.5;
        float v = asin(normal.y) / pi + 0.5;
        
        // Aplicar rotación manual
        vec2 uv_esferico = vec2(u, v) + rotacion;

        // Muestrear la textura
        vec4 tex_color = texture(textura_esfera, uv_esferico);
        
        // Mezclamos la textura con el albedo
        vec3 color_con_albedo = tex_color.rgb * albedo.rgb;
        
        // Si la textura tiene transparencias, esas zonas se vuelven NEGRAS
        vec3 color_con_fondo_negro = mix(vec3(0.0, 0.0, 0.0), color_con_albedo, tex_color.a);
        
        color_final = vec4(color_con_fondo_negro, albedo.a);
    }

    // Resultado final (Unshaded)
    COLOR = color_final;
}