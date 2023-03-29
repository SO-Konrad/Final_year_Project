extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

onready var size = $"Message/Label/OptionButton"
onready var setSeed= $"Message/Label/Seed/LineEdit"
var sizeOptions = [75,100,125]

func _on_Main_Menu_pressed():
	global.mapSize = sizeOptions[size.get_selected_id()]
	global.caveSeed = setSeed.text
	get_tree().change_scene("res://Main.tscn")


func _on_Quit_pressed():
	get_tree().change_scene("res://MainMenu.tscn")
