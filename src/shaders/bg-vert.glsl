#version 300 es

uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;

in vec4 vs_Pos;

out vec2 fs_UV;

void main() {
    fs_UV = vs_Pos.xy * 0.5 + 0.5;
    gl_Position = vs_Pos * u_Model * u_ViewProj;
}