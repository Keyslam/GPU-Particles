#pragma language glsl3

#ifdef VERTEX

#define DATA_TEXTURE_SIZE 128.0f

uniform sampler2D transform_texture;
uniform sampler2D lifetime_texture;

uniform float lifetime;

out vec4 particle_color;

vec4 position(mat4 transform, vec4 position) {
	vec2 texture_coords = vec2(
	   mod(gl_VertexID, DATA_TEXTURE_SIZE),
      floor(gl_VertexID / DATA_TEXTURE_SIZE)
   ) / DATA_TEXTURE_SIZE;

   vec4 transform_sample = Texel(transform_texture, texture_coords);
   vec4 lifetime_sample = Texel(lifetime_texture, VaryingTexCoord.xy);

   position.xy = vec2(transform_sample.x, transform_sample.y);

   float v = lifetime_sample.r / lifetime;
   particle_color = vec4(1.0f - v, 0.0f, 1.0f * v, 1.0f - v);
 
   return transform * position;
}

#endif

#ifdef PIXEL

in vec4 particle_color;

vec4 effect(vec4 color, sampler2D texture, vec2 texture_coords, vec2 screen_coords) {
   return particle_color * color;
}

#endif