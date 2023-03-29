extends Spatial
tool

var map = []
var edgeNodes = []
var centerNodes = []
var mapSize = 100
var caveSeed = ""
var fillPercent = 50;
var iterations = 6;

func _ready():
	var count = 0
	for i in 100:
		map = []
		edgeNodes = []
		centerNodes = []
		fillMap()                            #Randomly fills up array with 1 and 0
		
		for x in iterations:
			smooth_Map()                     #Runs cellular automata to smooth out map
			
		lable_zones()                      #Connects cave zones and sets player spawn in eligible position
		connect_Zones()
		
		var spawn = get_Spawn()
		var exit = get_Spawn()
		if isPath(spawn, exit):
			count += 1
	print(count)
	
	
func fillMap():
	if(caveSeed == ""):
		caveSeed = String(OS.get_system_time_msecs())
	
	seed(caveSeed.hash())
		
	for x in range(mapSize):
		map.append([])
		map[x]=[]
		for y in range(mapSize):
			map[x].append([])
			
			if (x == 0 || x==mapSize-1 || y==0 || y==mapSize-1):
				map[x][y] = 1
			else:
				map[x][y] = 1 if ((randi() % 100) < fillPercent) else 0

func smooth_Map():
	for x in range(mapSize):
		for y in range(mapSize):
			var neighbour_Count = get_wall_count(x,y)
			if(neighbour_Count>4):
				map[x][y] = 1
			elif(neighbour_Count<4):
				map[x][y] = 0
				
func lable_zones():
	var counter = 0
	for x in range (mapSize):
		for y in range(mapSize):
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
			if(neighbourX>=0 && neighbourX < mapSize && neighbourY>=0 && neighbourY < mapSize):
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
		create_passage(bestNode1,bestNode2,i)
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
					if (distance < bestDistance && !(connected.has([i,j])) && !connected.has([j,i])):
						bestDistance = distance
						bestNode1 = node1
						bestNode2 = node2
						bestJ = j
		create_passage(bestNode1,bestNode2,i)
		connected.push_back([i,bestJ])
		
		
func create_passage(node1,node2,pos):
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
			

func get_Spawn():
	var x = randi() % (len(centerNodes))
	while (len(centerNodes[x]) == 0):
		x = randi() % (len(centerNodes))
	var spawnNode = (randi() % (len(centerNodes[x])))
	var coords = centerNodes[x][spawnNode]
	return coords
	
func isPath(spawn, exit):
	var Dir = [ [0, 1], [0, -1], [1, 0], [-1, 0]]
	var q = []
	var arr = map
	 
	# insert the top right corner.
	q.append(spawn)
	 
	# until queue is empty
	while(len(q) > 0) :
		var p = q[0]
		q.remove(0)
		 
		arr[p[0]][p[1]] = -1
		 
		if p==spawn:
			return true
			 
		for i in range(4) :
		 
			var a = p[0] + Dir[i][0]
			var b = p[1] + Dir[i][1]
			 
			if(a >= 0 and b >= 0 and a < arr.length and b < arr[0].length and arr[a][b] != -1) :           
				q.append(a, b)
	return false
