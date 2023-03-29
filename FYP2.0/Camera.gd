extends Camera

func _process(delta):
	if(global.timeRemaining < 4):
		self.rotation_degrees.x = self.rotation_degrees.x + 1 * rand_range(-1,1)
		self.rotation_degrees.y = self.rotation_degrees.y + 1 * rand_range(-1,1)
		self.rotation_degrees.z = self.rotation_degrees.z + 1 * rand_range(-1,1)
