shader_type spatial;

uniform float outline_width = 0.05;
uniform vec3 outline_color = vec3(0.0); // color del contorno

void vertex() {
    // Mueve los vértices hacia afuera según su normal
    VERTEX += NORMAL * outline_width;
}

void fragment() {
    ALBEDO = outline_color;
}