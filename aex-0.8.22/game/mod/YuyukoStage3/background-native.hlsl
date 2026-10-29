SamplerState ground_sampler:register(s0);Texture2D ground_texture:register(t0);
SamplerState cloud_sampler:register(s1);Texture2D cloud_texture:register(t1);
cbuffer engine_data:register(b1){float4 screen_texture_size;float4 viewport;};
cbuffer user_data:register(b0){float4 eye;float4 forward;float4 right;float4 vertical;float4 fog;float4 farfog;float4 scroll;};
struct PS_Input{float4 sxy:SV_Position;float2 uv:TEXCOORD0;float4 col:COLOR0;};
float4 main(PS_Input input):SV_Target{
 float2 xy=input.uv*screen_texture_size.xy;
 if(any(xy<viewport.xy)||any(xy>viewport.zw))discard;
 float2 ndc=(xy-viewport.xy)/(viewport.zw-viewport.xy)*2-1;
 float2 lens=ndc*float2(384.0/408.0,448.0/472.0);
 float3 ray=forward.xyz+right.xyz*(lens.x*eye.w*forward.w)-vertical.xyz*(lens.y*eye.w);
 float3 color=fog.rgb;
 // Source3 layers, native X rotation=pi; extend the repeating sky to the fog horizon.
 [unroll]for(int layer=0;layer<3;layer++){
  float z=300-layer*100;
  float t=(z-eye.z)/ray.z;
  if(t<30||t>8000)continue;
  float3 hit=eye.xyz+ray*t;
   float2 uv=float2(hit.x/1024+0.5,0.5-(hit.y+200)/512);
   float4 tex;
   if(layer==0)tex=ground_texture.SampleLevel(ground_sampler,clamp(frac(uv*float2(2,1)),0.5/512,1-0.5/512),0);
   else tex=cloud_texture.SampleLevel(cloud_sampler,clamp(frac(uv*float2(4,2)+float2(0,layer==1?scroll.x:scroll.y)),0.5/256,1-0.5/256),0);
   float f=saturate((farfog.x-t)/(farfog.x-fog.w));
   float alpha=tex.a*(layer==0?1:128.0/255.0);
   float3 src=tex.rgb*(layer==0?96.0/255.0:1);
   if(layer==2)color=saturate(color+src*alpha*f);
   else color=lerp(color,lerp(fog.rgb,src,f),alpha);
 }
 return float4(color,1);
}
