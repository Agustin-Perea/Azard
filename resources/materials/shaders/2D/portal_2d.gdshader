shader_type canvas_item;
render_mode unshaded;

// --- UNIFORMS DE COLOR ---
uniform vec4 haloColor1 : source_color = vec4(0.0, 0.5, 1.0, 1.0); 
uniform vec4 haloColor2 : source_color = vec4(0.0, 0.0, 0.0, 0.0); 
uniform vec4 spiralColor : source_color = vec4(1.0, 1.0, 1.0, 1.0); 

uniform vec4 holeColorInner : source_color = vec4(0.0, 0.0, 0.0, 1.0); 
uniform vec4 holeColorOuter : source_color = vec4(0.1, 0.0, 0.2, 1.0); 

// --- CONTROLES ESENCIALES ---
uniform float holeSize : hint_range(0.0, 0.5, 0.01) = 0.2;

// --- POLAR UNIFORMS (MÁXIMA SUAVIDAD) ---
uniform sampler2D image : repeat_enable, filter_linear;
uniform float rotations : hint_range(0.0, 10.0, 0.5) = 1.0; 
uniform float depth : hint_range(0.0, 10.0, 0.1) = 0.5; 
uniform float spiralIntensity : hint_range(-10.0, 10.0, 0.1) = 1.0; 
uniform float shrinkSpeed : hint_range(-10.0, 10.0, 0.1) = 0.2; 
uniform float roationSpeed : hint_range(-10.0, 10.0, 0.1) = 0.1; 

void fragment() {
	// Desplazamiento respecto al centro (0.0 en el centro, 0.5 en los bordes)
	vec2 offsetUV = UV - 0.5;
	float centerDis = length(offsetUV);
	
	// --- COORDENADAS POLARES OPTIMIZADAS ---
	float angle = atan(offsetUV.y, offsetUV.x) + PI;
	vec2 polarUV;
	polarUV.x = (angle / (2.0 * PI)) * rotations + (centerDis * spiralIntensity);
	polarUV.y = centerDis * depth;

	// Muestreo de la textura de la espiral y aplicación de color directo
	vec3 spiralTex = texture(image, vec2(polarUV.x + TIME * roationSpeed, polarUV.y + TIME * shrinkSpeed)).rgb * spiralColor.rgb;

	// --- CÁLCULO DEL HALO ---
	float haloFactor = clamp((1.0 - centerDis * 2.0), 0.0, 1.0);
	vec3 haloRGB = mix(haloColor2.rgb, haloColor1.rgb, haloFactor);
	
	// Mezclamos el halo con la textura de la espiral
	haloRGB = mix(haloRGB, spiralTex * haloRGB, 0.7) * 3.0;
	
	// Atenuación suave del halo hacia los bordes externos del sprite
	float haloAlpha = smoothstep(0.5, 0.0, centerDis);

	// --- CÁLCULO DEL AGUJERO NEGRO ---
	float holeFactor = clamp(centerDis / holeSize, 0.0, 1.0);
	vec3 holeRGB = mix(holeColorInner.rgb, holeColorOuter.rgb, holeFactor);
	
	// Máscara dura/suave para transicionar entre el halo y el centro del agujero negro
	float blackHoleMask = smoothstep(holeSize - 0.04, holeSize, centerDis);
	
	// Mezcla final: Si está dentro del agujero usa holeRGB, si está fuera usa el halo
	vec3 final_rgb = mix(holeRGB, haloRGB, blackHoleMask);

	// --- SALIDA PARA CANVAS_ITEM (2D) ---
	float final_alpha = mix(blackHoleMask, 1.0, 1.0 - blackHoleMask) * haloAlpha; 
	
	// En 2D usamos COLOR en lugar de ALBEDO y ALPHA por separado
	COLOR = vec4(final_rgb, final_alpha);
}