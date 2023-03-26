extends Spatial
tool

var spawn 

onready var player = $"Player"
onready var objective = $"Objective"

var tile_size = 5

var map = []

# 0 = Live cell ( OPEN SPACE ) 
# 1 = Dead Cell ( CAVE WALL ) 

# Called when the node enters the scene tree for the first time.
func _ready():
	GenerateMap()

func GenerateMap():                #Connects cave zones and sets player spawn in eligible position
	spawn = get_node("CaveWalls").get_Spawn()
	player.transform.origin = (Vector3(spawn[0],0.75,spawn[1]))
	spawn = get_node("CaveWalls").get_Spawn()
	objective.transform.origin = (Vector3(spawn[0],0,spawn[1]))
	
	pass

func _on_Area_body_exited(_body):
	global.gemFound = global.timeRemaining
	objective.queue_free()
	
func _on_Area_body_entered(body):
	if(body == player):
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://GameComplete.tscn")
