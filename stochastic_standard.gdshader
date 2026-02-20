shader_type spatial;

#include "stochastic.gdshaderinc"

uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform ivec2 albedo_texture_size;

uniform sampler2D texture_ao : filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_roughness : hint_roughness_gray, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_metallic : filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_normal : hint_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale : hint_range(-16.0, 16.0);

uniform float ao_light_affect : hint_range(0.0, 1.0, 0.01);

varying vec3 uv1_triplanar_pos;

uniform float uv1_blend_sharpness : hint_range(0.0, 150.0, 0.001);
varying vec3 uv1_power_normal;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;
	
	vec3 albedo_tex = procedural_tiling_and_blending(texture_albedo, base_uv);
	ALBEDO = albedo_tex;

	vec3 roughness_tex = 	procedural_tiling_and_blending(texture_roughness, base_uv);
	vec3 metallic_tex = 	procedural_tiling_and_blending(texture_metallic, base_uv);
	vec3 ao_tex = 			procedural_tiling_and_blending(texture_ao, base_uv);
	ROUGHNESS = roughness_tex.r;
 	METALLIC = metallic_tex.r;

	// Normal Map: Enabled
	NORMAL_MAP = procedural_tiling_and_blending(texture_normal, base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;
	
	// Ambient Occlusion: Enabled
	AO = ao_tex.r;
	AO_LIGHT_AFFECT = ao_light_affect;
}