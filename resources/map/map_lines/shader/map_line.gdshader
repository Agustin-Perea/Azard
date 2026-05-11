shader_type canvas_item;

uniform float dash_count = 10.0; // Cuántos puntos por línea
uniform float dash_ratio = 0.5; // Proporción punto/espacio
uniform float speed = 1.0;

void fragment() {
	// UV.x es la longitud de la línea (0 a 1)
	// Multiplicamos por dash_count para repetir el patrón
	float pos = UV.x * dash_count - (TIME * speed);
	
	if (fract(pos) > dash_ratio) {
		discard;
	}
}