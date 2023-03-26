extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	global.timeRemaining = 300
	global.gemFound = -1



func _on_Main_Menu_pressed():
	get_tree().change_scene("res://Options.tscn")


func _on_Quit_pressed():
	get_tree().quit()
