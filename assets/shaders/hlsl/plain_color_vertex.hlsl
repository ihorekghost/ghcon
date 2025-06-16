//Output of the vertex shader
struct VSOutput {
    float4 position : SV_Position;
};

static const float2 vertices[3] = {
    float2( -1.0 , -1.0),
    float2( -1.0 ,  3.0),
    float2(  3.0 , -1.0),
};

// Vertex shader for full-screen triangle
VSOutput MainVS(uint id : SV_VertexID) {
    VSOutput output;

    output.position = float4(vertices[id], 0, 1.0);

    return output;
}