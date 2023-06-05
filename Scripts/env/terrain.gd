extends Node3D

@export var terrain_shader: ShaderMaterial
@export var highlight_scene: PackedScene

@export var event_bias: float

@export var highlight_density: int
@export var highlight_repartition: NoiseTexture2D
@export var highlight_low_margin: float
@export var highlight_k: int

var mesh: MeshInstance3D
var highlights

var heightmap: Image
var noise_map: Image
var height: float

# Called when the node enters the scene tree for the first time.
func initialize():
	mesh = $mesh
	highlights = $highlights
	
#	mesh.set_surface_override_material(0, terrain_shader)
	mesh.set_material_override(terrain_shader)
	
	var shader_height = terrain_shader.get_shader_parameter("heightmap")
#	await shader_height.changed
	heightmap = shader_height.get_image()
	
	height = terrain_shader.get_shader_parameter("height")
	
#	await highlight_repartition.changed
	noise_map = highlight_repartition.get_image()

func create_highlights():
	for child in highlights.get_children():
		highlights.remove_child(child)
		child.queue_free()
	
	var positions = Array()
	
	for x in range(highlight_density):
		for y in range(highlight_density):
#			var coord = Vector2(
#				remap(float(x)/float(highlight_density), 0.0, 1.0, 0.4, 0.6),
#				remap(float(y)/float(highlight_density), 0.0, 1.0, 0.4, 0.6)
#			)

			var coord = Vector2(
				float(x)/float(highlight_density),
				float(y)/float(highlight_density)
			)
			
			var chance = (noise_map.get_pixelv(coord * noise_map.get_height()).r + highlight_low_margin)
			var r = randf()
			
			if r > chance:
				continue
				
				
			var pos = Vector3.ONE * -1.0 + Vector3(coord.x, 0, coord.y) * 2.0
			pos.y = heightmap.get_pixelv(coord * heightmap.get_height()).r * height
			
			var highl = highlight_scene.instantiate()
			
			var mat = StandardMaterial3D.new()
#			highl.get_child(0).set_surface_override_material(0, mat)
			highl.get_child(0).set_material_override(mat)
			var e: Event
			
			if (r / chance) < event_bias:
				mat.albedo_color = Color(0.0,0.0,1.0)
				e = Event.new(Event.types.QUEST)
				
				e.event_name = "sample quest"
				
				var m = preload("res://Art/Models/tower.glb").instantiate()
				m.rotation = Vector3(randf() / 5.0, randf() * 2 * PI, randf() / 5.0)
				highl.add_child(m)
				
			else:
				mat.albedo_color = Color(1.0,0.0,0.0)
				e = Event.new(Event.types.SHOP)
				
				for i in range(1,6):
					var idx = -log(randf())/0.7
					
					idx = remap(idx, 0.0, 5.5, 0.0, 1.0)
					idx = clamp(idx, 0.0, 0.9999)
					
					idx = int(idx * Global.items.size())
					
					e.items.append(Global.items[idx])
			
				e.event_name = "sample shop"
				
				var m = preload("res://Art/Models/castle.glb").instantiate()
				m.rotation = Vector3(randf() / 5.0, randf() * 2 * PI, randf() / 5.0)
				m.position += Vector3(0.0, 5.0, 0.0)
				highl.add_child(m)
			
			highlights.add_child(highl)
			
			highl.event = e
			
			highl.position = pos
			positions.append(pos)
			
	for i in range(highlights.get_children().size()):
		if not highlights.get_children()[i] is highlight:
			continue
		highlights.get_children()[i].knn(positions, highlights.get_children(), i, highlight_k+1)
		
	return highlights.get_children().duplicate()

