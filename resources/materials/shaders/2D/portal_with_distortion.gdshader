shader_type spatial;
render_mode unshaded, cull_disabled;

// --- UNIFORMS DE COLOR (SELECCIÓN DIRECTA) ---
uniform vec4 haloColor1 : source_color = vec4(0.0, 0.5, 1.0, 1.0); 
uniform vec4 haloColor2 : source_color = vec4(0.0, 0.0, 0.0, 0.0); 
uniform vec4 spiralColor : source_color = vec4(1.0, 1.0, 1.0, 1.0); 

uniform vec4 holeColorInner : source_color = vec4(0.0, 0.0, 0.0, 1.0); 
uniform vec4 holeColorOuter : source_color = vec4(0.1, 0.0, 0.2, 1.0); 

// --- WARP UNIFORMS ---
uniform float distortionIntensity : hint_range(-10.0, 10.0, 0.1) = 1.0;
uniform float spiralDistortionIntensity : hint_range(-10.0, 10.0, 0.1) = 1.0;
uniform float holeSize : hint_range(0.0, 0.5, 0.01) = 0.2;

// --- POLAR UNIFORMS ---
uniform sampler2D image : repeat_enable, filter_linear_mipmap; 
uniform float rotations : hint_range(0.0, 10.0, 0.5) = 1.0; 
uniform float depth : hint_range(0.0, 10.0, 0.1) = 0.5; 
uniform float spiralIntensity : hint_range(-10.0, 10.0, 0.1) = 1.0; 
uniform float shrinkSpeed : hint_range(-10.0, 10.0, 0.1) = 0.2; 
uniform float roationSpeed : hint_range(-10.0, 10.0, 0.1) = 0.1; 

// Textura de la pantalla en 3D
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

vec2 toPolar(vec2 cartesian){
	float dist = length(cartesian);
	float angle = atan(cartesian.y, cartesian.x) + PI;
	return vec2(angle / (2.0 * PI), dist);
}

void fragment() {
	// Coordenadas y distancias suavizadas (HD)
	float centerDis = distance(UV, vec2(0.5));
	vec2 clipUV = UV * 2.0 - 1.0; 
	vec2 offsetUV = vec2(UV.x - 0.5, UV.y - 0.5);
	
	// Coordenadas polares para la espiral
	vec2 polarUV = toPolar(offsetUV);
	polarUV.x *= rotations;
	polarUV.x += polarUV.y * spiralIntensity;
	polarUV.y *= depth;

	// Textura de la espiral + Tinte de color
	vec4 polarTex = texture(image, vec2(polarUV.x + TIME * roationSpeed, polarUV.y + TIME * shrinkSpeed));
	polarTex.rgb *= spiralColor.rgb;

	// Cálculo del Halo alrededor del agujero
	float haloFactor = smoothstep(0.7, 1.0, 1.0 - length(offsetUV));
	vec4 halo = mix(haloColor2, haloColor1, haloFactor);
	
	halo = mix(halo, polarTex * halo, 0.7);
	halo.a *= smoothstep(0.0, 0.5, 0.5 - centerDis);

	// Deformación de Pantalla (Screen Warp de fondo)
	float ring = 1.0 - abs(length(clipUV));
	ring = smoothstep(0.0, 1.0, ring);
	
	vec2 fake_pixel_size = vec2(0.01); 
	vec2 offset = fake_pixel_size * ring * normalize(clipUV);
	vec2 spiralOffset = fake_pixel_size * max(0.0, 0.5 - centerDis) * vec2(0.5 - polarTex.r);
	
	vec2 final_screen_uv = SCREEN_UV + offset * distortionIntensity + spiralOffset * spiralDistortionIntensity;
	vec4 s = texture(screen_texture, final_screen_uv);
	
	// Mezcla del fondo distorsionado con el halo brillante
	vec3 final_rgb = mix(s.rgb, halo.rgb * 3.0, halo.a);

	// Renderizado del Agujero Negro central
	float blackHole = smoothstep(holeSize - 0.05, holeSize, centerDis);
	float holeFactor = smoothstep(0.0, holeSize, centerDis);
	vec4 hc = mix(holeColorInner, holeColorOuter, holeFactor);
	
	// Mezcla final aplicada directamente al ALBEDO
	final_rgb = mix(final_rgb, hc.rgb, 1.0 - blackHole);

	ALBEDO = final_rgb;
	ALPHA = 1.0;
}