//Output of the vertex shader
struct VSOutput {
    float4 position : SV_Position;
    float2 glyph_pos : TEXCOORD0; // UV in glyphs
    uint layer : TEXCOORD1;       // Layer index
};

static const float2 vertices[3] = {
    float2( -1.0 , -1.0),
    float2( -1.0 ,  3.0),
    float2(  3.0 , -1.0),
};

static const float2 uv[3] = {
    float2(0.0,  1.0),
    float2(0.0, -1.0), 
    float2(2.0,  1.0),
};

cbuffer Parameters: register(b0) {
    uint2 size_glyphs;         // Size of each layer, in glyphs
    float2 glyph_size_atlas;   // Size of one glyph in the font atlas, in texture coordinates
    float screen_range_pixels; // screen_glyph_size / atlas_glyph_size * pixel_range
}

// Vertex shader for full-screen triangle
VSOutput MainVS(uint id : SV_VertexID) {
    VSOutput output;

    output.glyph_pos = uv[id % 3] * (float2)size_glyphs;
    output.layer = id / 3;
    output.position = float4(vertices[id % 3], 0, 1.0);
    
    return output;
}