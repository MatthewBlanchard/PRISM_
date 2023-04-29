#pragma language glsl3

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
   return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
vec4 texture2DAA(Image tex, vec2 uv) {
   vec2 texsize = vec2(textureSize(tex,0));
   vec2 uv_texspace = uv*texsize;
   vec2 seam = floor(uv_texspace+.5);
   uv_texspace = (uv_texspace-seam)/fwidth(uv_texspace)+seam;
   uv_texspace = clamp(uv_texspace, seam-.5, seam+.5);
   return Texel(tex, uv_texspace/texsize);
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{

   vec4 texturecolor = texture2DAA(tex, texture_coords);
   //vec4 texturecolor = Texel(tex, texture_coords);
   return texturecolor * color;
}
#endif
