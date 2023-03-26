extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

class_name Colony

var num
var edgeSquares = [[]]
var centerSquares = [[]]


# Called when the node enters the scene tree for the first time.
func _init(num,edgeSquares,centerSquares):
	self.num = num
	self.edgeSquares = edgeSquares
	self.centerSquares = centerSquares
