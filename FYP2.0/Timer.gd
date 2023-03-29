extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	set_text(str(global.timeRemaining/60) + ":" + str("%02d" % (global.timeRemaining%60)))

func _on_Timer_timeout():
	global.timeRemaining -= 1
	if(global.timeRemaining == -1):
		get_tree().change_scene("res://GameOver.tscn")
	set_text(str(global.timeRemaining/60) + ":" + str("%02d" % (global.timeRemaining%60)))
