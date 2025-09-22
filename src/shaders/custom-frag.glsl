#version 300 es

precision highp float;

uniform vec4 u_Color;
uniform float u_Time;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col;

vec3 random(vec3 st) {
    vec3 p = vec3(dot(st, vec3(127.1, 311.7, 74.7)),
                  dot(st, vec3(269.5, 183.3, 246.1)),
                  dot(st, vec3(113.5, 271.9, 124.6)));
    return fract(sin(p) * 43758.5453123);
}

float worley3D(vec3 st) {
    vec3 i = floor(st);
    vec3 f = fract(st);
    
    float minDist = 1.0;
    
    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            for(int z = -1; z <= 1; z++) {
                vec3 neighbor = vec3(float(x), float(y), float(z));
                vec3 point = random(i + neighbor);
                
                point += 0.1 * sin(u_Time * 0.5 + 6.2831 * point);
                
                vec3 diff = neighbor + point - f;
                float dist = length(diff);
                
                minDist = min(minDist, dist);
            }
        }
    }
    
    return minDist;
}

void main() {
    vec3 pos = fs_Pos.xyz * 1.5;
    
    float worley = worley3D(pos);
    
    float r = sin(u_Time * 3.0) * 0.5 + 0.5;
    float g = sin(u_Time * 4.0 + 2.0) * 0.5 + 0.5;
    float b = sin(u_Time * 5.0 + 4.0) * 0.5 + 0.5;
    
    vec3 timeColor = vec3(r, g, b);
    
    float darkening = 0.7 + 0.3 * worley;
    
    vec3 finalColor = timeColor * darkening;
    
    float diffuseTerm = dot(normalize(fs_Nor.xyz), normalize(fs_LightVec.xyz));
    float lightIntensity = max(diffuseTerm, 0.0) + 0.3;
    
    out_Col = vec4(finalColor * lightIntensity, 1.0);
}