#version 300 es

precision highp float;

uniform vec4 u_Color;
uniform float u_Time;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;
in float v_EdgeFactor;

out vec4 out_Col;

void main() {

    // center
    vec3 yellow = vec3(1.0, 0.8314, 0.4118);
    vec3 redorange = vec3(1.0, 0.5765, 0.3294);

    vec3 blue = vec3(0.2, 0.2, 0.9);
    vec3 purple = vec3(0.4, 0.4, 0.9);

    // edges (edgefactor)
    vec3 red = vec3(0.9, 0.2, 0.1);
    vec3 redder = vec3(0.6, 0.1, 0.05);

    float centerMix = sin(u_Time * 3.0) * 0.5 + 0.5;
    vec3 centerColor = mix(yellow, purple, centerMix);

    float edgeMix = sin(u_Time * 2.5 + 1.0) * 0.5 + 1.0;
    vec3 edgeColor = mix(red, blue, edgeMix);

    float edgeBlend = pow(v_EdgeFactor, 5.0);
    vec3 finalColor = mix(centerColor, edgeColor, edgeBlend);
    
    float diffuseTerm = dot(normalize(fs_Nor.xyz), normalize(fs_LightVec.xyz));
    float lightIntensity = max(diffuseTerm, 0.0) + 0.3;

    out_Col = vec4(finalColor * lightIntensity, 0.75);
}