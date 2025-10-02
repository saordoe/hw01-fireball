#version 300 es

uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform float u_Time;

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec4 vs_Col;

out vec4 fs_Nor;
out vec4 fs_LightVec;
out vec4 fs_Col;
out vec4 fs_Pos;

const vec4 lightPos = vec4(5, 5, 3, 1);

float hash(float n) {
    return fract(sin(n) * 43758.5453);
}

float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float n = i.x + i.y * 57.0 + i.z * 113.0;
    return mix(
        mix(mix(hash(n + 0.0), hash(n + 1.0), f.x),
            mix(hash(n + 57.0), hash(n + 58.0), f.x), f.y),
        mix(mix(hash(n + 113.0), hash(n + 114.0), f.x),
            mix(hash(n + 170.0), hash(n + 171.0), f.x), f.y), f.z);
}

void main() {
    fs_Col = vs_Col;
    
    float trailLength = 4.0;
    float spinSpeed = 3.0;
    float twistFactor = 2.5;
    
    vec3 pos = vs_Pos.xyz;
    vec3 deformedPos = pos + vec3(0.0, 0.05, 0.0);
    
    deformedPos.y *= (1.0 + max(0.0, pos.y) * trailLength);
    
    float influence = (pos.y + 1.0) / 2.0;
    
    float radialDist = length(deformedPos.xz);
    
    float thinner = 0.4;
    deformedPos.xz *= thinner;
    
    radialDist = length(deformedPos.xz);
    
    float caveDepth = 0.3;
    float caveSharpness = 2.0;

    float caveInfluence = 1.0 - abs(influence * 2.0 - 1.0);
    float concaveCurve = pow(radialDist / thinner, caveSharpness) * caveDepth * caveInfluence;
    
    if (radialDist > 0.001) {
        vec2 radialDir = normalize(deformedPos.xz);
        deformedPos.xz -= radialDir * concaveCurve;
    }
    
    float taperExponent = 2.5;
    float taperAmount = 1.0 - pow(influence, taperExponent);
    deformedPos.xz *= taperAmount;
    
    radialDist = length(deformedPos.xz);
    
    float edgeInfluence = smoothstep(0.05, 0.15, radialDist);
    
    float angle = atan(deformedPos.z, deformedPos.x);
    
    float numFlames = 8.0;
    float flamePattern = sin(angle * numFlames + u_Time * 3.0) * 0.5 + 0.5;
    flamePattern += sin(angle * numFlames * 0.7 - u_Time * 2.5) * 0.3;
    flamePattern = pow(flamePattern, 2.0); // Sharpen the flames
    
    float flameTurbulence = noise(vec3(angle * 3.0, deformedPos.y * 0.5, u_Time * 2.0));
    flamePattern *= flameTurbulence;
    
    float baseInfluence = 1.0 - influence;
    float flameIntensity = baseInfluence * edgeInfluence * flamePattern;
    
    float flameExtension = 0.25 * flameIntensity;
    if (radialDist > 0.001) {
        vec2 radialDir = normalize(deformedPos.xz);
        deformedPos.xz += radialDir * flameExtension;
    }
    
    float flicker = sin(angle * numFlames + u_Time * 4.0) * cos(deformedPos.y * 2.0 - u_Time * 3.0);
    deformedPos.y += flicker * 0.1 * flameIntensity;
    
    float waveX = sin(deformedPos.y * 0.8 - u_Time * 1.5) * 0.1 * baseInfluence;
    float waveZ = cos(deformedPos.y * 0.6 - u_Time * 1.3) * 0.1 * baseInfluence;
    deformedPos.x += waveX;
    deformedPos.z += waveZ;
    
    float spin = u_Time * 5.0;
    mat2 rotate = mat2(cos(spin), -sin(spin), sin(spin), cos(spin));
    deformedPos.xz = rotate * deformedPos.xz;
    
    deformedPos += vec3(0.0, -2.0, 0.0);
    deformedPos.y += sin(u_Time * 1.501) / 3.0;
    
    vec4 dPos = vec4(deformedPos, 1.0);
    dPos.y = dPos.y + 1.0;
    
    vec3 normal = normalize(vs_Nor.xyz);
    
    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * normal, 0);
    
    vec4 mPos = u_Model * dPos;
    fs_Pos = mPos;
    fs_LightVec = lightPos - mPos;
    
    gl_Position = u_ViewProj * mPos;
}