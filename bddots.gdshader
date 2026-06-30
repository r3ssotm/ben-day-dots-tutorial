shader_type spatial;

// I suggest to make these globals, but you can have them local per instance as well.
global uniform float bddots_attenuation_factor;
global uniform float bddots_density;
global uniform vec2 bddots_pivot;
global uniform float bddots_rotation;
global uniform float bddots_softness;
global uniform sampler2D bddots_texture;
global uniform float bddots_falloff_threshold = 2.0;
global uniform float bddots_lit_threshold = 1.0;

uniform float bddots_intensity = 0.5;

uniform vec3 albedo: source_color = vec3(1);
uniform sampler2D albedo_texture: source_color, hint_default_white;

mat2 rot_mat2(float angle) {
	return mat2(vec2(cos(angle), sin(angle)), vec2(-sin(angle), cos(angle)));
}

float remap(vec2 in_min_max, vec2 out_min_max, float in_value) {
	float t = (in_value - in_min_max.x) / (in_min_max.y - in_min_max.x);
	return out_min_max.y * t + (1.0 - t) * out_min_max.x;
}

void fragment() {
	ALBEDO = texture(albedo_texture, UV).rgb * albedo;
	
}

void light() {
	vec2 uv = SCREEN_UV;
	vec2 scaled_uv = (uv - bddots_pivot) * bddots_density;
	
	float viewport_aspect = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
	scaled_uv.x *= viewport_aspect;
	
	vec2 rotated_uv = (scaled_uv - bddots_pivot) * rot_mat2(bddots_rotation) + bddots_pivot;
	
	float bddots_grid = texture(bddots_texture, rotated_uv).r;
	
	
	float attenuation = ATTENUATION;
	
	float light_value = clamp(dot(LIGHT, NORMAL), 0, 1) * attenuation;
	
	
	vec2 remap_in_min_max = vec2(-1,1);
	vec2 remap_out_min_max = vec2(bddots_lit_threshold - bddots_falloff_threshold, bddots_lit_threshold);
	float remapped_light = remap(remap_in_min_max, remap_out_min_max, 1.0 - light_value);
	
	float stepped_bddot_grid = smoothstep(remapped_light, remapped_light + bddots_softness, bddots_grid);
	
	vec3 bddots_diffuse = stepped_bddot_grid * pow(attenuation, bddots_attenuation_factor) * LIGHT_COLOR / PI;
	vec3 lambert_diffuse = clamp(dot(LIGHT, NORMAL), 0, 1) * ATTENUATION * LIGHT_COLOR / PI;
	
	vec3 blended_diffuse = mix(lambert_diffuse, bddots_diffuse, bddots_intensity);
	
	DIFFUSE_LIGHT += blended_diffuse;
}
