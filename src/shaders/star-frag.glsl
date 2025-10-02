#version 300 es

precision highp float;

uniform vec4 u_Color;
uniform float u_Time;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col;

void main() {

    vec3 cornsilk = vec3(1.0, 0.98, 0.89);
    vec3 yellow = vec3(1.0, 0.906, 0.525);

    float mixEffect = sin(u_Time * 3.0) * 0.5 + 0.5;

    vec3 finalColor = mix(cornsilk, yellow, mixEffect);
    
    float diffuseTerm = dot(normalize(fs_Nor.xyz), normalize(fs_LightVec.xyz));
    float lightIntensity = max(diffuseTerm, 0.0) + 0.3;
    
    out_Col = vec4(finalColor, 0.9);
}