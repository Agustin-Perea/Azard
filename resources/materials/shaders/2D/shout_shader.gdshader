shader_type canvas_item;
render_mode blend_add;

uniform sampler2D noise;

uniform vec2 center = vec2(0.5);

// Tiempo manual (slider)
uniform float time : hint_range(0.0, 10.0) = 0.0;

// Generación
uniform int max_rings = 20;
uniform float rings_per_second : hint_range(0.1, 20.0) = 2.0;
uniform float ring_lifetime : hint_range(0.1, 10.0) = 1.5;

// Escala
uniform float start_scale = 0.0;
uniform float max_scale = 2.5;

// Forma
uniform float inner_radius = 0.2;
uniform float outer_radius = 0.3;

// Líneas
uniform float line_count = 0.5;
uniform float line_density = 0.5;
uniform float line_falloff = 0.02;

uniform vec4 line_color = vec4(1.0,0.7,0.2,1.0);

vec2 polar_coordinates(vec2 uv, vec2 c, float zoom, float repeat)
{
    vec2 dir = uv - c;

    float radius = length(dir);
    float angle = atan(dir.y, dir.x)/(2.0*PI);

    return mod(
        vec2(radius * zoom, angle * repeat),
        1.0
    );
}

float ring_mask(
    float dist,
    float inner,
    float outer,
    float falloff
){
    return smoothstep(
        inner,
        inner + falloff,
        dist
    ) *
    (
        1.0 -
        smoothstep(
            outer,
            outer + falloff,
            dist
        )
    );
}

void fragment()
{
    vec2 uv = UV;

    float dist =
        length(
            uv - center
        );

    float alpha_total = 0.0;

    float spawn_interval =
        1.0 /
        rings_per_second;

    for(int i=0;i<max_rings;i++)
    {
        float spawn_time =
            float(i) *
            spawn_interval;

        float local_time =
            time -
            spawn_time;

        // todavía no apareció
        if(local_time < 0.0)
            continue;

        // ya murió
        if(local_time > ring_lifetime)
            continue;

        float t =
            local_time /
            ring_lifetime;

        float scale =
            mix(
                start_scale,
                max_scale,
                t
            );

        float fade =
            smoothstep(
                0.0,
                0.05,
                t
            ) *
            (
                1.0 -
                smoothstep(
                    0.8,
                    1.0,
                    t
                )
            );

        float mask =
            ring_mask(
                dist,
                inner_radius * scale,
                outer_radius * scale,
                line_falloff
            );

        vec2 polar_uv =
            polar_coordinates(
                uv,
                center,
                0.01,
                line_count
            );

        float lines =
            texture(
                noise,
                polar_uv
            ).r;

        float line_alpha =
            mask *
            line_density *
            fade;

        line_alpha =
            1.0 -
            smoothstep(
                line_alpha,
                line_alpha + line_falloff,
                lines
            );

        alpha_total += line_alpha;
    }

    alpha_total =
        clamp(
            alpha_total,
            0.0,
            1.0
        );

    COLOR.rgb =
        line_color.rgb;

    COLOR.a =
        line_color.a *
        alpha_total;
}