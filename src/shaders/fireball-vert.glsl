#version 300 es

uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform float u_Time;
uniform float u_FlameIntensity;
uniform float u_FlameLength;

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec4 vs_Col;

out vec4 fs_Nor;
out vec4 fs_LightVec;
out vec4 fs_Pos;

out float v_Displacement;
out float v_EdgeFactor;

const vec4 lightPos = vec4(5, 5, 3, 1);

vec3 hash3(vec3 p) {
    p = vec3(dot(p, vec3(127.1, 311.7, 74.7)),
             dot(p, vec3(269.5, 183.3, 246.1)),
             dot(p, vec3(113.5, 271.9, 124.6)));
    return fract(sin(p) * 43758.5453123);
}

float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    vec3 u = f * f * (3.0 - 2.0 * f);
    
    float a = hash3(i).x;
    float b = hash3(i + vec3(1.0, 0.0, 0.0)).x;
    float c = hash3(i + vec3(0.0, 1.0, 0.0)).x;
    float d = hash3(i + vec3(1.0, 1.0, 0.0)).x;
    float e = hash3(i + vec3(0.0, 0.0, 1.0)).x;
    float f1 = hash3(i + vec3(1.0, 0.0, 1.0)).x;
    float g = hash3(i + vec3(0.0, 1.0, 1.0)).x;
    float h = hash3(i + vec3(1.0, 1.0, 1.0)).x;
    
    return mix(mix(mix(a, b, u.x), mix(c, d, u.x), u.y),
               mix(mix(e, f1, u.x), mix(g, h, u.x), u.y), u.z);
}

float fBm(vec3 p) {
    float value = 0.0;
    float amplitude = 0.5;
    
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void main() {
    vec3 pos = vs_Pos.xyz;
    vec3 normal = normalize(vs_Nor.xyz);
   
    float radDist = length(pos.xz);
    v_EdgeFactor = smoothstep(0.75, 1.0, radDist);
   
    float flatten = 0.3;
    pos.y *= flatten;
   
    float caveDepth = u_FlameLength;
    float caveSharpness = 2.5;
   
    float concaveCurve = pow(radDist, caveSharpness) * caveDepth;
    pos.y -= concaveCurve;
   
    float edgeDeform = smoothstep(0.7, 1.0, radDist);
    pos.y -= edgeDeform * 0.2;
   
    pos.xz *= 1.1;
   
    vec3 tangentShift = vec3(0.0);
    if (radDist > 0.001) {
        vec2 radDir = normalize(pos.xz);
        float gradientY = -caveSharpness * caveDepth * pow(radDist, caveSharpness - 1.0);
        tangentShift = vec3(radDir.x * gradientY, -1.0, radDir.y * gradientY);
        normal = normalize(cross(
            vec3(-radDir.y, 0.0, radDir.x),
            tangentShift
        ));
    }
   
    float flameRegion = smoothstep(0.6, 1.0, radDist);
    
    vec3 noiseDomain1 = pos * 2.0 + vec3(0.0, u_Time * 1.2, 0.0);
    vec3 noiseDomain2 = pos * 4.5 + vec3(100.0, u_Time * 1.5, 50.0);
    vec3 noiseDomain3 = pos * 7.0 + vec3(200.0, u_Time * 0.9, 150.0);
    
    float tb1 = (fBm(noiseDomain1) - 0.5) * 2.0;
    float tb2 = (fBm(noiseDomain2) - 0.5) * 2.0;
    float tb3 = (fBm(noiseDomain3) - 0.5) * 2.0;
    
    float finalTurbulence = tb1 * 0.5 + tb2 * 0.3 + tb3 * 0.2;
    
    v_Displacement = finalTurbulence * 0.12 * flameRegion;
    v_Displacement *= u_FlameIntensity;
    
    vec3 deformedPos = pos + normal * v_Displacement;
    
    // rotation
    float growth = clamp(1.5 * sin(u_Time/1.5), 0.9, 1.5);
    mat2 rotation = mat2(cos(u_Time), -sin(u_Time), sin(u_Time), cos(u_Time)) * (growth);
    deformedPos.xz = rotation * deformedPos.xz;
   
    vec4 dPos = vec4(deformedPos, 1.0);
    dPos.y = dPos.y + 2.0;
    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * normal, 0.0);
    vec4 mPos = u_Model * dPos;
    fs_Pos = mPos;
    fs_LightVec = lightPos - mPos;
    gl_Position = u_ViewProj * mPos;
}