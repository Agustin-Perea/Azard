shader_type spatial;
render_mode blend_mix, cull_back, unshaded;

// Colores del escudo
uniform vec4 base_color : source_color = vec4(0.05, 0.1, 0.25, 1.0);
uniform vec4 shield_glow_color : source_color = vec4(0.0, 0.6, 1.0, 1.0);
uniform vec4 pattern_color : source_color = vec4(0.3, 0.8, 1.0, 1.0);

// Ajustes del patrón matemático
uniform float pattern_scale = 15.0;
uniform float pattern_sharpness = 0.08; // Valores más bajos = líneas más delgadas

// Efecto Fresnel (Brillo del borde)
uniform float fresnel_power = 3.5;
uniform float fresnel_intensity = 2.0;

// Animación
uniform float pulse_speed = 1.5;

varying vec3 v_local_pos;

void vertex() {
	v_local_pos = normalize(VERTEX);
}

// Función matemática para generar un patrón de celdas tipo red de energía
float cell_pattern(vec3 pos, float scale) {
	vec3 p = pos * scale;
	
	// Rompemos el espacio en componentes sinusoidales entrelazadas
	float d1 = dot(cos(p), sin(p.zxy));
	float d2 = dot(sin(p), cos(p.yzx));
	
	// Buscamos las crestas de la onda matemática para crear las líneas divisorias
	float edge = max(d1, d2);
	return smoothstep(1.0 - pattern_sharpness, 1.0, edge);
}

void fragment() {
	// ==========================================
	// 1. FRESNEL (Brillo de contorno de impacto)
	// ==========================================
	float fresnel = pow(1.0 - dot(normalize(NORMAL), normalize(VIEW)), fresnel_power);
	vec3 border_glow = shield_glow_color.rgb * fresnel * fresnel_intensity;

	// ==========================================
	// 2. PULSO DE ENERGÍA (Ondas concéntricas)
	// ==========================================
	// Creamos ondas que se mueven en base al tiempo usando la altura local de la esfera
	float wave = sin((v_local_pos.y * 8.0) - (TIME * pulse_speed)) * 0.5 + 0.5;
	// Atenuamos las ondas para que brillen más hacia los bordes de la esfera
	wave *= (fresnel + 0.2); 
	vec3 wave_glow = shield_glow_color.rgb * wave * 0.7;

	// ==========================================
	// 3. PATRÓN MATEMÁTICO DE CELDAS
	// ==========================================
	// Generamos la malla del escudo
	float grid = cell_pattern(v_local_pos, pattern_scale);
	
	// Hacemos que la red de energía brille intermitentemente en los bordes
	vec3 final_pattern = pattern_color.rgb * grid * (fresnel * 1.5 + 0.3);

	// ==========================================
	// RESULTADO COMPUESTO
	// ==========================================
	// Color base sólido del escudo mezclado con la red matemática
	ALBEDO = mix(base_color.rgb, final_pattern, grid);

	// EMISSION: Sumamos todos los componentes lumínicos (borde, ondas y patrón)
	EMISSION = border_glow + wave_glow + final_pattern;

	// ALPHA: 1.0 para mantener el fondo completamente opaco como querías
	ALPHA = 1.0;
}