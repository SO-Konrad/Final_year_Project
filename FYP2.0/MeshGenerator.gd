extends MeshInstance
tool

var despawnWall
var map = []
var edgeNodes = []
var centerNodes = []
var squareGrid:SquareGrid
var mesh_data = []
var vertices = PoolVector3Array()
var normals = PoolVector3Array()
var vertices2 = PoolVector3Array()
var normals2 = PoolVector3Array()

onready var node = $"."
onready var horizontal_exit = $"Horizontal_Exit"
onready var diagonal_exit = $"Diagonal_Exit"
onready var cone = preload("res://Cone.tscn")
onready var crystal = preload("res://Crystal.tscn")

var horizontal = true
var fillPercent = 50;
var iterations = 6;

func _ready():
	fillMap()                            #Randomly fills up array with 1 and 0
	
	for x in iterations:
		smooth_Map()                     #Runs cellular automata to smooth out map
		
	lable_zones()                      #Connects cave zones and sets player spawn in eligible position
	connect_Zones()   
	mesh_data.resize(Mesh.ARRAY_MAX)
	squareGrid = SquareGrid.new(map)
	add_textures()
	draw_Cave()
	
func fillMap():
	if(global.caveSeed == ""):
		global.caveSeed = String(OS.get_system_time_msecs())
	
	seed(global.caveSeed.hash())
		
	for x in range(global.mapSize):
		map.append([])
		map[x]=[]
		for y in range(global.mapSize):
			map[x].append([])
			
			if (x == 0 || x==global.mapSize-1 || y==0 || y==global.mapSize-1):
				map[x][y] = 1
			else:
				map[x][y] = 1 if ((randi() % 100) < fillPercent) else 0

func smooth_Map():
	for x in range(global.mapSize):
		for y in range(global.mapSize):
			var neighbour_Count = get_wall_count(x,y)
			if(neighbour_Count>4):
				map[x][y] = 1
			elif(neighbour_Count<4):
				map[x][y] = 0
				
func lable_zones():
	var counter = 0
	for x in range (global.mapSize):
		for y in range(global.mapSize):
			if (map[x][y] == 0):
				edgeNodes.append([])
				centerNodes.append([])
				floodFill(counter,x,y)
				counter+=1
	return
	
func floodFill(var counter, var x, var y):
#	map[x][y] = 10
#	if(map[x+1][y] == 0):
#		floodFill(counter, x+1, y)
#	if(map[x][y+1] == 0):
#		floodFill(counter, x,y+1)
#	if(map[x-1][y] == 0):
#		floodFill(counter, x-1,y)
#	if(map[x][y-1] == 0):
#		floodFill(counter, x,y-1)
#	if(get_wall_count(x,y)%10 == 0):
#		centerNodes[counter].append([x,y])
#	else:
#		edgeNodes[counter].append([x,y])
	#### Legacy code that would create a Stack Overflow, improvement is below

	var stack = []
	stack.append([x,y])
	
	while stack:
		var currentNode = stack.pop_front()
		x = currentNode[0]
		y = currentNode[1]
		map[x][y] = 10
		if(map[x+1][y] == 0):
			map[x+1][y] = 10
			stack.append([x+1,y])
		if(map[x][y+1] == 0):
			map[x][y+1] = 10
			stack.append([x,y+1])
		if(map[x-1][y] == 0):
			map[x-1][y] = 10
			stack.append([x-1,y])
		if(map[x][y-1] == 0):
			map[x][y-1] = 10
			stack.append([x,y-1])
		if(get_wall_count(x,y)%10 == 0):
			centerNodes[counter].append([x,y])
		else:
			edgeNodes[counter].append([x,y])
	return
	
func get_wall_count(gridX, gridY):
	var wallCount = 0
	for neighbourX in range(gridX-1,gridX+2):
		for neighbourY in range(gridY-1,gridY+2):
			if(neighbourX>=0 && neighbourX < global.mapSize && neighbourY>=0 && neighbourY < global.mapSize):
				if(neighbourX!=gridX || neighbourY!=gridY):
					wallCount+= map[neighbourX][neighbourY]
			else:
				wallCount+=1
	return wallCount
	
func connect_Zones():
	var connected = []
	for i in range(len(edgeNodes)):
		var bestDistance = 100000
		var bestNode1
		var bestNode2
		var bestJ
		for j in range(len(edgeNodes)):
			if(i==j):
				continue
			for node1 in edgeNodes[i]:
				for node2 in edgeNodes[j]:
					var distance = pow(node1[0] - node2[0], 2) + pow(node1[1] - node2[1],2)
					if (distance < bestDistance && !(connected.has([j,i]))):
						bestDistance = distance
						bestNode1 = node1
						bestNode2 = node2
						bestJ = j
		create_passage(bestNode1,bestNode2)
		connected.push_back([i,bestJ])
	for i in range(len(edgeNodes)):
		var bestDistance = 100000
		var bestNode1
		var bestNode2
		var bestJ
		for j in range(len(edgeNodes)):
			if(i==j):
				continue
			for node1 in edgeNodes[i]:
				for node2 in edgeNodes[j]:
					var distance = pow(node1[0] - node2[0], 2) + pow(node1[1] - node2[1],2)
					if (distance < bestDistance && !(connected.has([i,j]))):
						bestDistance = distance
						bestNode1 = node1
						bestNode2 = node2
						bestJ = j
		create_passage(bestNode1,bestNode2)
		connected.push_back([i,bestJ])
		
func create_passage(node1,node2):
	var x_Range = float(abs(node1[0] - node2[0]))
	var y_Range = float(abs(node1[1] - node2[1]))
	var shortestX = node1 if (node1[0] < node2[0]) else  node2
	var longestX = node1 if (node1[0] > node2[0]) else  node2
	var shortestY = node1 if (node1[1] < node2[1]) else  node2
	var longestY = node1 if (node1[1] > node2[1]) else  node2
	
	var gradientCounter = float(0)
	if(x_Range > y_Range):
		var gradient = float(y_Range/x_Range)
		if(shortestY == longestX):
			gradient *= -1
		#print("Gradient: ", gradient)
		for i in range(shortestX[0],longestX[0]):
			gradientCounter+=gradient
			map[i][shortestX[1]+gradientCounter] = 0
			map[i][shortestX[1]+gradientCounter+1] = 0
			#print("X: ",i, "Y: ",shortestX[1]+gradientCounter)
	else:
		var gradient = float(x_Range/y_Range)
		if(shortestY == longestX):
			gradient *= -1
		#print("Gradient: ", gradient)
		for i in range(shortestY[1],longestY[1]):
			gradientCounter+=gradient
			map[shortestY[0]+gradientCounter][i] = 0
			map[shortestY[0]+gradientCounter+1][i] = 0
			#print("X: ",shortestY[0]+gradientCounter, "Y: ",i)
	
func add_textures():
	for x in centerNodes:
		for y in x:
			var chance = randi()%10
			if(chance == 0):
				var object = cone.instance()
				object.transform.origin = (Vector3(y[0],3-(object.mesh.height/2),y[1]))
				add_child(object)
	for x in edgeNodes:
		for y in x:
			var chance = randi()%10
			if(chance == 0):
				var object = cone.instance()
				object.transform.origin = (Vector3(y[0],3-(object.mesh.height/2),y[1]))
				add_child(object)
	for x in edgeNodes:
		for y in x:
			var chance = randi()%10
			if(chance == 0):
				var object = crystal.instance()
				var scaleWeight = rand_range(.1,.25)
				object.scale = Vector3(scaleWeight,scaleWeight,scaleWeight)
				if(squareGrid.squares[y[0]][y[1]-1].value == 2):
					object.transform.origin = (Vector3(y[0]+.75,rand_range(1,2),y[1]-.25))
					object.rotate_y(270)
				elif(squareGrid.squares[y[0]][y[1]-1].value == 4):
					object.transform.origin = (Vector3(y[0]+.75,rand_range(1,2),y[1]-.75))
					object.rotate_y(315)
				elif(squareGrid.squares[y[0]-1][y[1]-1].value == 4):
					object.transform.origin = (Vector3(y[0],rand_range(1,2),y[1]-1))
				elif(squareGrid.squares[y[0]-1][y[1]-1].value == 8):
					object.transform.origin = (Vector3(y[0]-.75,rand_range(1,2),y[1]-.75))
					object.rotate_y(45)
				elif(squareGrid.squares[y[0]-1][y[1]].value == 8):
					object.transform.origin = (Vector3(y[0]-1,rand_range(1,2),y[1]))
					object.rotate_y(90)
				elif(squareGrid.squares[y[0]-1][y[1]].value == 1):
					object.transform.origin = (Vector3(y[0]-.75,rand_range(1,2),y[1]+.75))
					object.rotate_y(135)
				elif(squareGrid.squares[y[0]][y[1]].value == 1):
					object.transform.origin = (Vector3(y[0],rand_range(1,2),y[1]+1))
					object.rotate_y(180)
				elif(squareGrid.squares[y[0]][y[1]].value == 2):
					object.transform.origin = (Vector3(y[0]+.75,rand_range(1,2),y[1]+.75))
					object.rotate_y(225)
				object.rotate_x(rand_range(-30,30))
				add_child(object)

func draw_Cave():
	for x in range(squareGrid.squares.size()):
		for y in range(squareGrid.squares[x].size()):
			y = y
			marching_Square(squareGrid.squares[x][y])
			
	for x in range(12):
		vertices2.push_back(vertices[0])
		normals2.push_back(normals[0])
		vertices.remove(0)
		normals.remove(0)
		
	mesh_data[Mesh.ARRAY_VERTEX] = vertices
	mesh_data[Mesh.ARRAY_NORMAL] = normals
	mesh = Mesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)
	var collision = mesh.create_trimesh_shape()
	var body = StaticBody.new()
	var collision_node = CollisionShape.new()
	node.add_child(body)
	body.add_child(collision_node)
	collision_node.shape = collision
	
	var vector = vertices2[0]
	
	if(vertices2[0].z != vertices2[6].z):
		horizontal = false;
		
	if(horizontal):
		horizontal_exit.transform.origin = (Vector3(vector.x-1, 1.5, vector.z+1))
	else:
		diagonal_exit.transform.origin = (Vector3(vector.x-2.23, 1.5, vector.z+.5))
		
	mesh_data[Mesh.ARRAY_VERTEX] = vertices2
	mesh_data[Mesh.ARRAY_NORMAL] = normals2
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)
	collision = mesh.create_trimesh_shape()
	despawnWall = StaticBody.new()
	collision_node = CollisionShape.new()
	node.add_child(despawnWall)
	despawnWall.add_child(collision_node)
	collision_node.shape = collision
	
func marching_Square(var square):
	if(square.value == 0):
		return;
	elif(square.value == 1):
		generate_Mesh([square.centerLeft,square.centerBottom])
	elif(square.value == 2):
		generate_Mesh([square.centerBottom,square.centerRight,])
	elif(square.value == 3):
		generate_Mesh([square.centerLeft,square.centerRight])
	elif(square.value == 4):
		generate_Mesh([square.centerRight,square.centerTop])
	elif(square.value == 5):
		generate_Mesh_2([square.centerBottom,square.centerLeft,square.centerRight,square.centerTop])
	elif(square.value == 6):
		generate_Mesh([square.centerBottom,square.centerTop])
	elif(square.value == 7):
		generate_Mesh([square.centerLeft,square.centerTop])
	elif(square.value == 8):
		generate_Mesh([square.centerTop,square.centerLeft])
	elif(square.value == 9):
		generate_Mesh([square.centerTop,square.centerBottom])
	elif(square.value == 10):
		generate_Mesh_2([square.centerTop,square.centerLeft,square.centerRight,square.centerBottom])
	elif(square.value == 11):
		generate_Mesh([square.centerTop,square.centerRight])
	elif(square.value == 12):
		generate_Mesh([square.centerRight,square.centerLeft])
	elif(square.value == 13):
		generate_Mesh([square.centerRight,square.centerBottom])
	elif(square.value == 14):
		generate_Mesh([square.centerBottom,square.centerLeft])
	elif(square.value == 15):
		return
		
func generate_Mesh(var a):
	vertices.push_back(a[0].position)
	vertices.push_back(a[1].position)
	vertices.push_back(a[1].position + Vector3(0,3,0))
	vertices.push_back(a[0].position)
	vertices.push_back(a[1].position + Vector3(0,3,0))
	vertices.push_back(a[0].position + Vector3(0,3,0))
	
	var norm1 = calc_norm(a[0].position,a[1].position,a[1].position + Vector3(0,3,0))
	
	normals.push_back(norm1)
	normals.push_back(norm1)
	normals.push_back(norm1)
	normals.push_back(norm1)
	normals.push_back(norm1)
	normals.push_back(norm1)
	
func generate_Mesh_2(var a):
	vertices.push_back(a[0].position)
	vertices.push_back(a[1].position)
	vertices.push_back(a[1].position + Vector3(0,3,0))
	vertices.push_back(a[0].position)
	vertices.push_back(a[1].position + Vector3(0,3,0))
	vertices.push_back(a[0].position + Vector3(0,3,0))
	
	vertices.push_back(a[2].position)
	vertices.push_back(a[3].position + Vector3(0,3,0))
	vertices.push_back(a[3].position)
	vertices.push_back(a[2].position)
	vertices.push_back(a[2].position + Vector3(0,3,0))
	vertices.push_back(a[3].position + Vector3(0,3,0))
	
	var norm1 = calc_norm(a[0].position,a[1].position,a[1].position + Vector3(0,3,0))
	var norm2 = calc_norm(a[2].position,a[3].position + Vector3(0,3,0),a[3].position)
	
	normals.push_back(norm1)
	normals.push_back(norm1)
	normals.push_back(norm1)
	normals.push_back(norm1)
	normals.push_back(norm1)
	normals.push_back(norm1)
	
	normals.push_back(norm2)
	normals.push_back(norm2)
	normals.push_back(norm2)
	normals.push_back(norm2)
	normals.push_back(norm2)
	normals.push_back(norm2)
	
func calc_norm(var a, var b, var c):
	var U = b-a
	var V = c-a
	
	var normal = Vector3()
	
	normal.x = (U.z*V.y) - (U.y*V.z)
	normal.y = (U.x*V.z) - (U.z*V.x)
	normal.z = (U.y*V.x) - (U.x*V.y)
	
	return normal
	
func get_Spawn():
	var x = randi() % (len(centerNodes))
	while (len(centerNodes[x]) == 0):
		x = randi() % (len(centerNodes))
	var spawnNode = (randi() % (len(centerNodes[x])))
	var coords = centerNodes[x][spawnNode]
	return coords

class SquareGrid:
	var squares = []

	func _init(map):
		var nodeCountX = len(map)
		var nodeCountY = len(map[0])
		
		var controlNodes = []
		
		for x in range(nodeCountX):
			controlNodes.append([])
			for y in range(nodeCountY):
				controlNodes[x].append([])
				var pos = Vector3(x,0,y)
				controlNodes[x][y] = Control_Node.new(pos,map[x][y] == 1)
		
		for x in range(nodeCountX-1):
			squares.append([])
			for y in range(nodeCountY-1):
				squares[x].append([])
				squares[x][y] = Square.new(controlNodes[x][y], controlNodes[x+1][y], controlNodes[x][y+1], controlNodes[x+1][y+1])

class Square:
	var topLeft: Control_Node
	var topRight: Control_Node
	var bottomLeft: Control_Node
	var bottomRight: Control_Node

	var centerTop: Sub_Node
	var centerRight: Sub_Node
	var centerLeft: Sub_Node
	var centerBottom: Sub_Node
	
	var value = 0

	func _init(_topLeft,_topRight,_bottomLeft,_bottomRight):
		topLeft = _topLeft
		topRight = _topRight
		bottomLeft = _bottomLeft
		bottomRight = _bottomRight
		
		centerTop = topLeft.right
		centerRight = bottomRight.above
		centerBottom = bottomLeft.right
		centerLeft = bottomLeft.above
		
		if(topLeft.active):
			value+=8
		if(topRight.active):
			value+=4
		if(bottomRight.active):
			value+=2
		if(bottomLeft.active):
			value+=1

class Sub_Node:
	export(Vector3) var position
	export var vertexIndex = -1

	func _init(_pos):
		position = _pos
  
class Control_Node extends Sub_Node:
	export(bool) var active
	var above: Sub_Node
	var right: Sub_Node

	func _init(_pos, _active).('position'):
		pass
		active = _active
		above = Sub_Node.new(_pos + (Vector3.FORWARD/2) )
		right = Sub_Node.new(_pos + (Vector3.RIGHT/2) )
		


func _on_Area_body_exited(_body):
	mesh.surface_remove(1)
	node.remove_child(despawnWall)
	
	if(horizontal):
		horizontal_exit.visible = true
	else:
		diagonal_exit.visible = true
