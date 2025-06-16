//Output of the vertex shader
struct VSOutput {
    float4 position : SV_Position;
    float2 glyph_pos : TEXCOORD0; // UV in glyphs
    uint layer : TEXCOORD1; // Layer index
};


cbuffer Parameters: register(b0) {
    uint2 size_glyphs; // Size of each layer, in glyphs
    float2 glyph_size_atlas; // Size of one glyph in the font atlas, in texture coordinates
    float screen_range_pixels; // screen_glyph_size / atlas_glyph_size * pixel_range
}

//Resources
Texture2D font_atlas_texture : register(t0);
Buffer<float2> glyphs_positions: register(t1);
Buffer<uint> glyphs : register(t2);

//Samplers
SamplerState font_atlas_sampler : register(s0);

//Source: https://github.com/Chlumsky/msdfgen   (
float median(float r, float g, float b) {
    return max(min(r, g), min(max(r, g), b));
}
//  )

float4 MainPS(VSOutput input) : SV_Target {
    //Make sure we're not going out of bounds
    const uint glyph_x = min(floor(input.glyph_pos.x), size_glyphs.x - 1);
    const uint glyph_y = min(floor(input.glyph_pos.y), size_glyphs.y - 1);

    //1D index into `glyphs` buffer
    const uint index = glyph_y * size_glyphs.x + glyph_x + (size_glyphs.x * size_glyphs.y * input.layer);
    
    //Extract color and ASCII code
    const float r = (float)((glyphs[index]) & 255) / 255.0;
    const float g = (float)((glyphs[index] >> 8) & 255) / 255.0;
    const float b = (float)((glyphs[index] >> 16) & 255) / 255.0;
    const uint char = ((glyphs[index] >> 24) & 255);
    
    //Extract glyph metrics
    const float2 glyph_pos_atlas = glyphs_positions[char];

    //Texture atlas sample position
    const float2 sample_pos = glyph_pos_atlas + (glyph_size_atlas * frac(input.glyph_pos));

    //Source: https://github.com/Chlumsky/msdfgen (
    const float3 msd = font_atlas_texture.Sample(font_atlas_sampler, sample_pos).rgb;
    const float sd = median(msd.r, msd.g, msd.b);
    const float screenPxDistance = screen_range_pixels*(sd - 0.5);
    const float opacity = clamp(screenPxDistance + 0.5, 0.0, 1.0);
    // )

    return float4(r, g, b, char != 2 ? opacity : 1.0f);

    
}


