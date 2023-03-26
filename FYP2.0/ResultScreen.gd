extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	set_text("Gem found: "  + str((global.timeTotal - global.gemFound)/60) + ":" + str("%02d" % ((global.timeTotal-global.gemFound)%60)) + 
	"\nExit found: " + str((global.timeTotal - global.timeRemaining)/60) + ":" + str("%02d" % ((global.timeTotal-global.timeRemaining)%60)))


