//Output of the vertex shader
struct VSOutput {
    float4 position : SV_Position;
};

cbuffer Parameters: register(b1) {
    float4 color;
}

float4 MainPS(VSOutput input) : SV_Target {
    return color;
}
