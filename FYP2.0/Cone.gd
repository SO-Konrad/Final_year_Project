extends MeshInstance

# Called when the node enters the scene tree for the first time.
func _ready():
			mesh.height = rand_range(.5,1.8)
			mesh.bottom_radius = rand_range(.1,.5)

