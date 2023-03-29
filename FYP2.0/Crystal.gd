extends MeshInstance


var colors = ["50981e1e","50255991","5088a7e4","5059b93a","50c66e9b","503a8028","5066c1a2","503c565f","50fffec7","50a7d761","50edea2d","503a828a","50b05e8d","507b4f5d","50c1412e","50763a8c","50175637","503f0c50"]
# Called when the node enters the scene tree for the first time.
func _ready():
	var material = SpatialMaterial.new()
	var num = randi() % len(colors)
	material.albedo_color = (colors[num])
	material.metallic = .6
	material.roughness = .03
	material.anisotropy_enabled = true
	material.anisotropy = 1
	set_material_override(material)
	for x in get_children():
		x.set_material_override(material)


