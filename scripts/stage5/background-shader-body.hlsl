// Source-specific pixel rasterizer: preserves independent depth-test/write, which AEX's sprite API couples.
SamplerState ground_sampler:register(s0); Texture2D ground_texture:register(t0);
SamplerState tree_sampler:register(s1); Texture2D tree_texture:register(t1);
SamplerState mist_sampler:register(s2); Texture2D mist_texture:register(t2);
SamplerState screen_texture_sampler:register(s4); Texture2D screen_texture:register(t4);
cbuffer engine_data:register(b1){float4 screen_texture_size;float4 viewport;};
cbuffer user_data:register(b0){float4 eye;float4 forward;float4 right;float4 vertical;float4 fog;float4 ending;float4 tree1;float4 tree2;};
struct PS_Input{float4 sxy:SV_Position;float2 uv:TEXCOORD0;float4 col:COLOR0;};
float4 main(PS_Input input):SV_Target
{
 float2 xy=input.uv*screen_texture_size.xy;
 if(any(xy<viewport.xy)||any(xy>viewport.zw))discard;
 float2 ndc=(xy-viewport.xy)/(viewport.zw-viewport.xy)*2-1;
 // Native Stage camera copies supervisor camera3 (408x472), then crops to the384x448 play area.
 float2 lens=ndc*float2(384.0/408.0,448.0/472.0);
 float3 ray=forward.xyz+right.xyz*(lens.x*eye.w*forward.w)-vertical.xyz*(lens.y*eye.w);
 float3 color=ending.yzw;float depth=vertical.w;
 [loop]for(int i=0;i<60;i++){
  float4 g=geometry[i];float4 dims=dimensions[i];bool billboard=g.w==1||g.w==2;
  float4 tint=float4(1,1,1,g.w==3?128.0/255.0:1);
  // Native47f29f scales projected-unit length by0.5 before applying centered +/-0.5 anchors.
  if(billboard)dims.xy*=0.5;
  if(billboard){float4 vm=g.w==1?tree1:tree2;g.x+=vm.x;tint.rgb=vm.yzw;}
  float t=billboard?dot(g.xyz-eye.xyz,forward.xyz):(g.z-eye.z)/ray.z;
  if(t<right.w||t>vertical.w||t>depth+0.00001)continue;
  float3 hit=eye.xyz+ray*t;float2 uv;
  if(billboard)uv=float2(dot(hit-g.xyz,right.xyz)/dims.x+0.5,0.5-dot(hit-g.xyz,vertical.xyz)/dims.y);
  else uv=float2((hit.x-g.x)/dims.x+0.5,0.5-(hit.y-g.y)/dims.y);
  if(any(uv<0)||any(uv>1))continue;
  float4 tex;
  if(billboard)tex=tree_texture.SampleLevel(tree_sampler,uv,0);
  else if(g.w==0)tex=ground_texture.SampleLevel(ground_sampler,float2(frac(uv.x*dims.z),uv.y),0);
  else tex=mist_texture.SampleLevel(mist_sampler,float2(frac(uv.x*dims.z),uv.y),0);
  float alpha=tex.a*tint.a;
  // TH18 alpha test rejects transparent texels before RGB blending or depth writes.
  if(alpha<1.0/255.0)continue;
  float3 src=tex.rgb*tint.rgb;
  // Native FOGTABLEMODE=0, FOGVERTEXMODE=LINEAR: clamp at vertices, then interpolate.
  if(!billboard){
   float3 tl=g.xyz+float3(-dims.x/2,dims.y/2,0);
   float3 tr=g.xyz+float3(dims.x/2,dims.y/2,0);
   float3 bl=g.xyz+float3(-dims.x/2,-dims.y/2,0);
   float3 br=g.xyz+float3(dims.x/2,-dims.y/2,0);
   float4 z=float4(dot(tl-eye.xyz,forward.xyz),dot(tr-eye.xyz,forward.xyz),dot(bl-eye.xyz,forward.xyz),dot(br-eye.xyz,forward.xyz));
   float4 factors=saturate((ending.x-abs(z))/(ending.x-fog.w));
   float4 bary=uv.x+uv.y<=1?float4(1-uv.x-uv.y,uv.x,uv.y,0):float4(0,1-uv.y,1-uv.x,uv.x+uv.y-1);
   src=lerp(fog.rgb,src,dot(factors,bary));
  }
  color=saturate(src*alpha+color*(g.w==3?1:1-alpha));
  // 481210 calls454820: billboard Z-test is active, but Z-write is OFF.
  // 480160 calls4547e0: true3D ground and mist write depth, with native LESSEQUAL.
  if(!billboard)depth=t;
 }
 return float4(color,1);
}
