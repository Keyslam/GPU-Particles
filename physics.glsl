#pragma language glsl3

#ifdef VERTEX

vec4 position(mat4 transform, vec4 position) {
  return transform * position;
}

#endif

#ifdef PIXEL

uniform float dt;
uniform float lifetime;

uniform sampler2D transform_texture;
uniform sampler2D lifetime_texture;

void effect() {
   vec4 transform_sample = Texel(transform_texture, VaryingTexCoord.xy);
   vec4 lifetime_sample = Texel(lifetime_texture, VaryingTexCoord.xy);

   transform_sample.xy += (transform_sample.ba * dt);

   lifetime_sample.x += dt;

   love_Canvases[1] = lifetime_sample;

   if (lifetime_sample.x > lifetime) {
      love_Canvases[0] = vec4(1.0f);
      return;
   }

   love_Canvases[0] = transform_sample;
}

#endif