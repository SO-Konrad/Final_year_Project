extends MeshInstance


var colors = ["981e1e","255991","88a7e4","59b93a","c66e9b","3a8028","66c1a2","3c565f","fffec7","a7d761","edea2d","3a828a","b05e8d","7b4f5d","c1412e","763a8c","175637","3f0c50"]
# Called when the node enters the scene tree for the first time.
func _ready():
	var material = SpatialMaterial.new()
	var num = randi() % len(colors)
	material.albedo_color = (colors[num])
	material.metallic = 1
	material.roughness = .82
	material.anisotropy = 1
	set_material_override(material)
	for x in get_children():
		x.set_material_override(material)


