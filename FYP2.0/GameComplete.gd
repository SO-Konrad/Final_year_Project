extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_Main_Menu_pressed():
	get_tree().change_scene("res://MainMenu.tscn")


func _on_Quit_pressed():
	get_tree().quit()
