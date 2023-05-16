#pragma language glsl3

#ifdef PIXEL

uniform vec4 bg_color;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
   vec4 pixel = Texel(tex, texture_coords);

   if (pixel.a == 0) {
      pixel = bg_color;
   } else {
      pixel = pixel * color;
   }


   return pixel;
}
#endif