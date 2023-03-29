extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	if(global.gemFound != -1):
		set_text("Gem found: "  + str((global.timeTotal - global.gemFound)/60) + ":" + str("%02d" % ((global.timeTotal-global.gemFound)%60)) + 
		"\nExit found: Failed!")
	else:
		set_text("Gem found: Failed!" +
		"\nExit found: Failed!")
