extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _on_Area_body_exited(_body):
	set_text("Escape the cave!")
	self.margin_left = -135
