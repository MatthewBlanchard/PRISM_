#pragma language glsl3

#ifdef PIXEL

uniform vec4 viewport;


vec2 coord;
float alpha_sum = 0;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
   vec4 pixel = Texel(tex, texture_coords);

   vec2 tex_size = textureSize(tex, 0);
   vec2 pixel_dimensions = vec2(1.0/tex_size.x, 1.0/tex_size.y);

   float x = viewport[0] / tex_size.x;
   float y = viewport[1] / tex_size.y;
   float w = viewport[2] / tex_size.x;
   float h = viewport[3] / tex_size.y;


   // Left
   coord = texture_coords + pixel_dimensions * vec2(-1,0);
   if (coord.x > x) {
      alpha_sum += Texel(tex, coord).a;
   }

   // Right
   coord = texture_coords + pixel_dimensions * vec2(1,0);
   if (coord.x < x + w) {
      alpha_sum += Texel(tex, coord).a;
   }

   // Up
   coord = texture_coords + pixel_dimensions * vec2(0,1);
   if (coord.y < y + h) {
      alpha_sum += Texel(tex, coord).a;
   }

   // Down
   coord = texture_coords + pixel_dimensions * vec2(0,-1);
   if (coord.y > y) {
      alpha_sum += Texel(tex, coord).a;
   }

   if (pixel.a == 0 && alpha_sum > 0) {
      pixel = vec4(0,0,0,1);
   }

   return pixel * color;
}
#endif