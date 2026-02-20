void triangle_grid(vec2 uv, out float w1, out float w2, out float w3, out ivec2 vertex1, out ivec2 vertex2, out ivec2 vertex3) {
	uv *= 3.464; // 2 * sqrt(3)
	
	const mat2 grid_to_skewed_grid = mat2(
		vec2(1.0, 0.0),
		vec2(-0.57735027, 1.15470054)
	);
	
	vec2 skewed_coord = grid_to_skewed_grid * uv;
	
	ivec2 base_id = ivec2(floor(skewed_coord));
	vec3 temp = vec3(fract(skewed_coord), 0);
	temp.z = 1.0 - temp.x - temp.y;
	
	if (temp.z > 0.0) {
		w1 = temp.z;
		w2 = temp.y;
		w3 = temp.x;
		vertex1 = base_id;
		vertex2 = base_id + ivec2(0, 1);
		vertex3 = base_id + ivec2(1, 0);
	} else {
		w1 = -temp.z;
		w2 = 1.0 - temp.y;
		w3 = 1.0 - temp.x;
		vertex1 = base_id + ivec2(1, 1);
		vertex2 = base_id + ivec2(1, 0);
		vertex3 = base_id + ivec2(0, 1);
	}
}

vec2 hash(vec2 p) {
	return fract(sin ((p) * mat2(vec2(127.1, 311.7), vec2(269.5, 183.3))) * 43758.5453);
}

vec3 procedural_tiling_and_blending(sampler2D input, vec2 uv) {
	float w1, w2, w3;
	ivec2 vertex1, vertex2, vertex3;
	triangle_grid(uv, w1, w2, w3, vertex1, vertex2, vertex3);
	
	vec2 uv1 = uv + hash(vec2(vertex1));
	vec2 uv2 = uv + hash(vec2(vertex2));
	vec2 uv3 = uv + hash(vec2(vertex3));
	
	vec2 duvdx = dFdx(uv);
	vec2 duvdy = dFdy(uv);
	
	vec3 I1 = textureGrad(input, uv1, duvdx, duvdy).rgb;
	vec3 I2 = textureGrad(input, uv2, duvdx, duvdy).rgb;
	vec3 I3 = textureGrad(input, uv3, duvdx, duvdy).rgb;
	
	vec3 color = w1 * I1 + w2 * I2 + w3 * I3;
	
	return color;
}