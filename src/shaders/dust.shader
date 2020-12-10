shader_type canvas_item;

uniform vec2 resolution;
uniform vec3 color_1;
uniform vec3 color_2;
uniform vec3 color_3;
uniform vec3 color_4;

float random(in vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123); 
}

float noise(in vec2 st) {
	vec2 i = floor(st);
	vec2 f = fract(st);
	
	float a = random(i);
	float b = random(i + vec2(1.0, 0.0));
	float c = random(i + vec2(0.0, 1.0));
	float d = random(i + vec2(1.0, 1.0));
	
	vec2 u = f * f * (3.0 - 2.0 * f);
	
	return mix(a, b, u.x) +
		(c - a) * u.y * (1.0 - u.x) +
		(d - b) * u.x * u.y;
}

float fbm(in vec2 st) {
	float v = 0.0;
	float a = 0.5;
	vec2 shift = vec2(100.0);
	
	mat2 rot = mat2(vec2(cos(0.5), sin(0.5)),
					vec2(-sin(0.5), cos(0.5)));
	
	for(int i = 0; i < 5; ++i) {
		v += a * noise(st);
		st = rot * st * 2.0 + shift;
		a *= 0.5;
	}
	
	return v;
}

void fragment() {
	vec2 st = FRAGCOORD.xy / resolution.xy * 3.0;
	vec3 color = vec3(0.0);
	
	vec2 q = vec2(0.0);
	q.x = fbm(st + 0.0 * TIME);
	q.y = fbm(st + vec2(1.0));
	
	vec2 r = vec2(0.0);
	r.x = fbm(st + 1.0 * q + vec2(1.7, 9.2) + 0.15);
	r.y = fbm(st + 1.0 * q + vec2(0.280, -0.550) + 0.126 * (TIME * 0.1));
	
	float f = fbm(st + r);
	
	color = mix(color_1,
				color_2,
				clamp((f*f) * 2.0, 0.0, 1.0));
	
	color = mix(color,
				color_3,
				clamp(length(q), 0.0, 1.0));
	
	color = mix(color,
				color_4,
				clamp(r.x, 0.0, 1.0));
	
	COLOR = vec4((f*f*f + 0.6*f*f + 0.5*f) * color, 0.6);
}