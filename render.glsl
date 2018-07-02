#pragma language glsl3

#ifdef VERTEX

#define DATA_TEXTURE_SIZE 16.0f

uniform sampler2D transform_texture;
uniform sampler2D lifetime_texture;

uniform float lifetime;

out vec4 particle_color;

vec4 position(mat4 transform, vec4 position) {
   int particleID = gl_VertexID / 4 * gl_InstanceID;

	vec2 texture_coords = vec2(
	   mod(particleID, DATA_TEXTURE_SIZE),
      floor(particleID / DATA_TEXTURE_SIZE)
   ) / DATA_TEXTURE_SIZE;

   vec4 transform_sample = Texel(transform_texture, texture_coords);
   vec4 lifetime_sample = Texel(lifetime_texture, VaryingTexCoord.xy);

   position.xy = vec2(transform_sample.x, transform_sample.y);

   float v = lifetime_sample.r / lifetime;
   particle_color = vec4(1.0f, 1.0f, 1.0f, 1.0f - v);
 
   position.xy += VertexTexCoord.xy * 20;

   return transform * position;
}

#endif

#ifdef PIXEL

in vec4 particle_color;

vec4 effect(vec4 color, sampler2D img, vec2 texture_coords, vec2 screen_coords) {
   vec4 pixel = Texel(img, texture_coords);
   return pixel * particle_color;
}

#endif