extends RigidBody2D

var size
#Legacy Code that was used to test Cellular Automata
func place_tile(_pos,_size):
	position = _pos
	size = _size
	var s = RectangleShape2D.new()
	s.extents = size
	$CollisionShape2D.shape = s
