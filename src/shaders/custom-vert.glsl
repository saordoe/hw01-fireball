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

void main() {
    fs_Col = vs_Col;
    
    vec3 pos = vs_Pos.xyz;
    
    float waveX = sin(pos.y * 3.0 + u_Time * 2.0) * 0.5;
    float waveY = cos(pos.x * 2.0 + u_Time * 1.5) * 0.6;
    float waveZ = sin(pos.x * 4.0 + pos.y * 4.0 + u_Time * 1.8) * 0.4;
    
    float distance = length(pos.xy);
    float ripple = sin(distance * 6.0 - u_Time * 4.0) * 0.3 * exp(-distance * 1.0);
    
    vec3 deformedPos = pos + vec3(waveX, waveY, waveZ + ripple);
    
    float twist = u_Time * 1.0;
    float twistAmount = pos.z * 1.0;
    mat3 twistMatrix = mat3(
        cos(twist + twistAmount), -sin(twist + twistAmount), 0.0,
        sin(twist + twistAmount), cos(twist + twistAmount), 0.0,
        0.0, 0.0, 1.0
    );
    deformedPos = twistMatrix * deformedPos;
    
    vec4 dPos = vec4(deformedPos, 1.0);
    
    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);
    
    vec4 mPos = u_Model * dPos;
    fs_Pos = mPos;
    fs_LightVec = lightPos - mPos;
    
    gl_Position = u_ViewProj * mPos;
}