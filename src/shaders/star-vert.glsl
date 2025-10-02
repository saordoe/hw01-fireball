#version 300 es

uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform float u_Time;

uniform float u_Speed;

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

    mat3 rotateX = mat3(
        1.0, 0.0, 0.0,
        0.0, cos(u_Time), -sin(u_Time),
        0.0, sin(u_Time), cos(u_Time)
    );

    vec3 pos = vs_Pos.xyz / vec3(2.0, 2.0, 2.0); // scaled down
    vec3 deformedPos = pos + vec3(0.0, 1.2, 0.0);

    // back and forth
    deformedPos.y = sin(u_Time * 1.501)/3.0 + deformedPos.y;

    // rotate
    float spin = u_Time * u_Speed;
    mat2 rotate = mat2(cos(spin), -sin(spin), sin(spin), cos(spin));
    deformedPos.xz = rotate * deformedPos.xz;
    deformedPos *= vec3(0.8);
    deformedPos.y += 0.2;

    // offset
    vec4 dPos = vec4(deformedPos, 1.0);

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);
    
    vec4 mPos = u_Model * dPos;
    fs_Pos = mPos;
    fs_LightVec = lightPos - mPos;
    
    gl_Position = u_ViewProj * mPos;
}