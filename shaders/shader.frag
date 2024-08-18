#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

float gaussian(float x, float mean, float sigma);
float norm_gaussian(float x, float mean, float sigma);
vec3 lenia_growth(vec3 x);
vec3 lenia_filters(float distance);
float random(vec2 st);

uniform vec2 uSize;
uniform float uTime;
uniform sampler2D uTexture;

out vec4 fragColor;

const float simulationScale = .02;

vec2 wrap(vec2 uv) {
    uv.x = mod(uv.x, 1.0);
    uv.y = mod(uv.y, 1.0);
    return uv;
}

vec2 toSimulation(vec2 uv) {
    return (uv - vec2(.5, .5)) / simulationScale;
}

vec2 fromSimulation(vec2 uv) {
    return wrap(uv * simulationScale + vec2(.5, .5));
}

vec4 get(vec2 uv) {
    return texture(uTexture, fromSimulation(uv));
}

const int kernelResolution = 11;
const float kernelMaxDistance = 2;
const vec2 kernelunitVector = vec2(1, 1) * (kernelMaxDistance / kernelResolution);

void main() {
    vec2 xy = FlutterFragCoord() / uSize;
    vec2 uv = toSimulation(xy);

    if (fract(uTime / 30) < 0.1) {
        vec3 rand = vec3(random(uv),
        random(uv),
        random(uv)
        );
        float gauss = gaussian(length(uv) / 4, 0, .5);
        vec3 value = rand * gauss;
        fragColor = vec4(value, 1.0);
        return;
    }

    vec3 sum = vec3(0);
    for (int i = -kernelResolution; i < kernelResolution; ++i) {
        for (int j = -kernelResolution; j < kernelResolution; ++j) {
            vec2 vector = vec2(i, j) * kernelunitVector;
            float distance = length(vector);
            if (distance > kernelMaxDistance) {
                continue;
            }
            vec3 values = get(uv + vector).rgb;
            vec3 cross = vec3(length(values.rg), values.g - values.b * 2, values.b);
            vec3 weight = lenia_filters(distance);
            sum += cross * weight;
        }
    }
    vec3 growth = lenia_growth(sum);
    vec3 pixelValue = get(uv).rgb;
    fragColor = vec4(vec3(pixelValue + growth * .04), 1.0);
}

vec3 lenia_filters(float distance) {
    return vec3(
    gaussian(distance, 2, .3),
    gaussian(distance, 2, .3),
    gaussian(distance, 4, .3)
    );
}

vec3 lenia_growth(vec3 x) {
    return vec3(
    -1 + 2 * norm_gaussian(x.r, 2, 1),
    -1 + 2 * norm_gaussian(x.g, 4, 1),
    -1 + 2 * norm_gaussian(x.b, 3, 2)
    );
}


float gaussian(float x, float mean, float sigma) {
    float coeff = 1.0 / (sigma * sqrt(2.0 * 3.141592653589793));
    float exponent = -((x - mean) * (x - mean)) / (2.0 * sigma * sigma);
    return coeff * exp(exponent);
}

float norm_gaussian(float x, float mean, float sigma) {
    float exponent = -((x - mean) * (x - mean)) / (2.0 * sigma * sigma);
    return exp(exponent);
}

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}