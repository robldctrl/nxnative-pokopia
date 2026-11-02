// The present: the frame drawn into the drawable, cropped (nvn_mtl.m present_pipeline). fx.x: the Display menu's Vivid colours strength (0 = the game's bytes as they are),
// a saturation and contrast lift on the gamma-encoded picture, for screens that show it flatter than the Switch 2's
#include <metal_stdlib>
using namespace metal;
struct V { float4 p [[position]]; float2 uv; };
vertex V vs(uint id [[vertex_id]]) { float2 uv = float2((id << 1) & 2, id & 2); V o; o.p = float4(uv * float2(2, -2) + float2(-1, 1), 0, 1); o.uv = uv; return o; }
struct Crop { float4 rect; float4 edge; float4 fx; };
fragment float4 fs(V in [[stage_in]], texture2d<float> t [[texture(0)]], sampler s [[sampler(0)]], constant Crop& c [[buffer(0)]]) {
    float4 col = t.sample(s, clamp(in.uv * c.rect.zw + c.rect.xy, c.edge.xy, c.edge.zw));
    float v = c.fx.x;
    if (v > 0) {
        float l = dot(col.rgb, float3(0.2126, 0.7152, 0.0722));
        col.rgb = mix(float3(l), col.rgb, 1 + 0.45 * v);            // saturation
        col.rgb = (col.rgb - 0.5) * (1 + 0.15 * v) + 0.5;           // contrast around mid grey
        col.rgb = saturate(col.rgb);
    }
    return col;
}
