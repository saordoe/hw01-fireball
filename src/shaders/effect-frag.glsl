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
    vec3 yellowish = vec3(1.0, 0.949, 0.714); // FFF2B6 in hex
    vec3 blueish = vec3(0.741, 0.894, 1.0);
    vec3 pinkish = vec3(1.0, 0.741, 0.741);

    float mixEffect = sin(u_Time * 3.0) * 0.5 + 0.5;

    vec3 finalColor = mix(pinkish, cornsilk, mixEffect);
    
    float diffuseTerm = dot(normalize(fs_Nor.xyz), normalize(fs_LightVec.xyz));
    float lightIntensity = max(diffuseTerm, 0.0) + 0.3;
    
    out_Col = vec4(finalColor * lightIntensity, 0.9);
}