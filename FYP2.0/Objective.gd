extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_exited",self,"_on_Area_body_exited")


func _on_Area_body_exited(_node):
	print("body_exited")
	emit_signal("body_exited")
