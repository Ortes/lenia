#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    vec2 xy = FlutterFragCoord().xy;
    vec2 uv = xy / uSize;

    int sum = 0;
    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            if (i == 0 && j == 0) {
                continue;
            }
            if (texture(uTexture, uv + vec2(i, j) / uSize).r > 0.5) {
                sum++;
            }
        }
    }
    if (sum < 2) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    } else if (sum == 2) {
        fragColor = texture(uTexture, uv);
    } else if (sum == 3) {
        fragColor = vec4(1.0, 1.0, 1.0, 1.0);
    } else {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }
}
