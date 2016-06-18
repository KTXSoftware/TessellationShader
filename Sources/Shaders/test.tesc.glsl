#version 450

layout(vertices = 3) out;

in vec3 vPosition[];

out vec3 tcPosition[];

uniform float TessLevelInner;
uniform float TessLevelOuter;

#define ID gl_InvocationID

void patch_main() {
	gl_TessLevelInner[0] = TessLevelInner;
	gl_TessLevelOuter[0] = TessLevelOuter;
	gl_TessLevelOuter[1] = TessLevelOuter;
	gl_TessLevelOuter[2] = TessLevelOuter;
}

void main() {
	tcPosition[ID] = vPosition[ID];
}
