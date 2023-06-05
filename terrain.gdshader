shader_type spatial;

uniform sampler2D heightmap;

uniform sampler2D grass_texture;

uniform float texture_tiling;

uniform float height;

uniform float light_intensity;

varying float textures;
varying vec3 n;

void vertex()
{
	float vertex_pos = texture(heightmap, UV).r * height;
	
	VERTEX.y = vertex_pos;
	
	vec2 h = vec2(0.01, 0);
	float dx = (texture(heightmap, UV + h).r - texture(heightmap, UV).r) / h.x;
	float dz = (texture(heightmap, UV + h.yx).r - texture(heightmap, UV).r) / h.x;
	vec3 normal = normalize(vec3(dx, light_intensity, dz));
	
	NORMAL = normal;
	n = normal;
//	vec3 normal = normalize(vec3(texture(heightmap, UV - h).r - texture(heightmap, UV + h).r, 2.0 * h.x, texture(heightmap, UV - h.yx).r - texture(height_map, coord + h.yx).r));
}

void fragment() {
	// Place fragment code here.
	NORMAL = (VIEW_MATRIX * vec4(n, 0.0)).xyz;
	
	ALBEDO = texture(grass_texture, UV * texture_tiling).rgb;
}
