#version 300 es
precision highp float;

uniform float u_Time;
in vec2 fs_UV;
out vec4 out_Col;

vec3 random3(vec2 p) {
    return fract(sin(vec3(dot(p,vec2(127.1, 311.7)),
                          dot(p,vec2(269.5, 183.3)),
                          dot(p, vec2(420.6, 631.2))
                    )) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    float a = random3(i).x;
    float b = random3(i + vec2(1.0, 0.0)).x;
    float c = random3(i + vec2(0.0, 1.0)).x;
    float d = random3(i + vec2(1.0, 1.0)).x;
    
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    
    for (int i = 0; i < 5; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void main() {
    vec2 uv = fs_UV;
    vec2 nebCoord = uv * 3.0 + u_Time * 0.05;
    
    float noise1 = fbm(nebCoord);
    float noise2 = fbm(nebCoord * 2.0 + 100.0);
    
    float neb = noise1 * 0.6 + noise2 * 0.4;
    neb = smoothstep(0.2, 0.8, neb);
    
    vec3 color1 = vec3(0.05, 0.1, 0.3);
    vec3 color2 = vec3(0.1, 0.05, 0.4);
    vec3 color3 = vec3(0.3, 0.1, 0.5);
    
    vec3 nebColor = mix(color1, color2, noise1);
    nebColor = mix(nebColor, color3, noise2 * 0.5);
    
    vec3 finalColor = mix(vec3(0.02, 0.05, 0.15), nebColor, neb * 0.5) * 0.7;
    
    out_Col = vec4(finalColor, 1.0);
}