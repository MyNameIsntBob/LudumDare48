extends Node2D

export var cell_size = 256

export (NodePath) var tileMapPath
export (NodePath) var laddersMapPath

var first = false

var tileMap
var laddersMap
var graph 

var showLines = false

const TEST = preload("res://Prefabs/Face.tscn")


func _ready():
	graph = AStar2D.new()
	tileMap = get_node(tileMapPath)
	laddersMap = get_node(laddersMapPath)
	createMap()

func findPath(start, end):
#	var first_point = graph.get_closest_position_in_segment(start)
#	var finish = graph.get_closest_position_in_segment(end)
	var first_point = graph.get_closest_point(start)
	var finish = graph.get_closest_point(end)
	var path = graph.get_id_path(first_point, finish)
	
	if (len(path) == 0):
		return path
	
	var actions = []
	
	var lastPos
	
	for point in path:
		var pos = graph.get_point_position(point)

		lastPos = pos

		actions.append(pos)
	return actions

func createConections():
	var space_state = get_world_2d().direct_space_state
	var used_cells = tileMap.get_used_cells()

	var points = graph.get_points()
	for point in points:
		if graph.get_point_position(point) - Vector2(0, 1) in used_cells:
			break
			
		var onGround = graph.get_point_position(point) + Vector2(0, 1) in used_cells
		var closestRight = -1
		var closestLeftDrop = -1
		var closestRightDrop = -1
		var closestBelow = -1
		var pos = graph.get_point_position(point)	
		var stat = cellType(pos, true, true)

		var pointsToJoin = []
		var noBiJoin = []

	

		for newPoint in points:
			if graph.get_point_position(newPoint) - Vector2(0, 1) in used_cells:
				break
			var newPos = graph.get_point_position(newPoint)
			if ((stat[1] == 0 or newPos[0] == pos[0] + cell_size) and newPos[1] == pos[1] and newPos[0] > pos[0]):
				if closestRight < 0 or newPos[0] < graph.get_point_position(closestRight)[0]: 
					closestRight = newPoint
			if (stat[0] == -1):
				if (newPos[0] == pos[0] - cell_size and newPos[1] > pos[1]):
					if closestLeftDrop < 0 or newPos[1] < graph.get_point_position(closestLeftDrop)[1]:
						closestLeftDrop = newPoint
				if (newPos[1] >= pos[1] and newPos[1] <= pos[1] and 
					newPos[0] > pos[0] - (cell_size * 2) and newPos[0] < pos[0]) and cellType(newPos, true, true)[1] == -1 :
						pointsToJoin.append(newPoint)


			if !onGround and newPos[0] == pos[0] and newPos[1] > pos[1]:
				if closestBelow < 0 or newPos[1] < graph.get_point_position(closestBelow)[1]:
					closestBelow = newPoint

			if (stat[1] == -1):
				if (newPos[0] == pos[0] + cell_size and newPos[1] > pos[1]):
					if closestRightDrop < 0 or newPos[1] < graph.get_point_position(closestRightDrop)[1]:
						closestRightDrop = newPoint
				if (newPos[1] >= pos[1] and newPos[1] <= pos[1] and 
					newPos[0] < pos[0] + (cell_size * 2) and newPos[0] > pos[0]) and cellType(newPos, true, true)[0] == -1 :
						pointsToJoin.append(newPoint)

		if (closestBelow > 0):
			if (graph.get_point_position(closestBelow)[1] == pos[1] + cell_size):
				pointsToJoin.append(closestBelow)
			else:
				noBiJoin.append(closestBelow)
				
		if (closestRight > 0):
			pointsToJoin.append(closestRight)

		for joinPoint in pointsToJoin:
			graph.connect_points (point, joinPoint)
		for joinPoint in noBiJoin:
			graph.connect_points (point, joinPoint, false)

func _draw():
	if !showLines:
		return

	var space_state = get_world_2d().direct_space_state
	var used_cells = tileMap.get_used_cells()

	var points = graph.get_points()
	for point in points:
		
		if graph.get_point_position(point) - Vector2(0, 1) in used_cells:
			break
		var closestRight = -1
		var closestLeftDrop = -1
		var closestRightDrop = -1
		var closestBelow = -1
		var pos = graph.get_point_position(point)	
		var stat = cellType(pos, true, true)

		var pointsToJoin = []
		var noBiJoin = []

	

		for newPoint in points:
			if graph.get_point_position(newPoint) - Vector2(0, 1) in used_cells:
				break
			
			var newPos = graph.get_point_position(newPoint)
			if ((stat[1] == 0 or newPos[0] == pos[0] + cell_size) and newPos[1] == pos[1] and newPos[0] > pos[0]):
				if closestRight < 0 or newPos[0] < graph.get_point_position(closestRight)[0]: 
					closestRight = newPoint
			if (stat[0] == -1):
				if (newPos[0] == pos[0] - cell_size and newPos[1] > pos[1]):
					if closestLeftDrop < 0 or newPos[1] < graph.get_point_position(closestLeftDrop)[1]:
						closestLeftDrop = newPoint
				if (newPos[1] >= pos[1] and newPos[1] <= pos[1] and 
					newPos[0] > pos[0] - (cell_size * 2) and newPos[0] < pos[0]) and cellType(newPos, true, true)[1] == -1 :
						pointsToJoin.append(newPoint)


			var result = space_state.intersect_ray(pos, newPos, [], 1)
			if !result and newPos[0] == pos[0] and newPos[1] > pos[1]:
				if closestBelow < 0 or newPos[1] < graph.get_point_position(closestBelow)[1]:
					closestBelow = newPoint

			if (stat[1] == -1):
				if (newPos[0] == pos[0] + cell_size and newPos[1] > pos[1]):
					if closestRightDrop < 0 or newPos[1] < graph.get_point_position(closestRightDrop)[1]:
						closestRightDrop = newPoint
				if (newPos[1] >= pos[1] and newPos[1] <= pos[1] and 
					newPos[0] < pos[0] + (cell_size * 2) and newPos[0] > pos[0]) and cellType(newPos, true, true)[0] == -1 :
						pointsToJoin.append(newPoint)

		if (closestBelow > 0):
			if (graph.get_point_position(closestBelow)[1] == pos[1] + cell_size):
				pointsToJoin.append(closestBelow)
			else:
				noBiJoin.append(closestBelow)
				
		if (closestRight > 0 and !graph.get_point_position(closestRight) - Vector2(0, 1) in used_cells and
			!graph.get_point_position(point) - Vector2(0, 1) in used_cells):
			pointsToJoin.append(closestRight)

		for joinPoint in pointsToJoin:
			draw_line(pos, graph.get_point_position(joinPoint), Color(255, 0, 0), 1)
		for joinPoint in noBiJoin:
			draw_line(pos, graph.get_point_position(joinPoint), Color(255, 0, 0), 1)
			
func createMap():
#	Reset if you already created the map
	graph.clear()
	for node in get_children():
		remove_child(node)
		node.queue_free()
	
	var space_state = get_world_2d().direct_space_state
	var cells = tileMap.get_used_cells()
	
	var ladders = laddersMap.get_used_cells()
	
	for cell in ladders:
		createPoint(cell)
		createPoint(cell + Vector2(0, 1))
	
	for cell in cells:
		var above = Vector2(cell[0], cell[1] - 1)
	#	var evenAboveThat = Vector2(cell[0], cell[1] - 2)
		if !above in tileMap.get_used_cells():
			createPoint(cell)
			var stat = cellType(cell)
			
			if stat[0] == -1:
				createPoint(cell + Vector2(-1, 0))
				pass
			if stat[1] == -1:
				createPoint(cell + Vector2(1, 0))
				pass
		
#		var stat = cellType(cell)
#
#		if (stat):
#			createPoint(cell)
			
#			if stat[1] == -1:
#				var pos = tileMap.map_to_world(Vector2(cell[0] + 1, cell[1]))
#				var pto = Vector2(pos[0], pos[1] + 1000)
#				var result = space_state.intersect_ray(pos, pto, [], 1)
#				if (result):					
#					createPoint(tileMap.world_to_map(result.position))
#
#			if stat[0] == -1:
#				var pos = tileMap.map_to_world(Vector2(cell[0] - 1, cell[1]))
#				var pto = Vector2(pos[0], pos[1] + 1000)
#				var result = space_state.intersect_ray(pos, pto, [], 1)
#				if (result):					
#					createPoint(tileMap.world_to_map(result.position))
	createConections()
	update()

func cellType(pos, global = false, isAbove = false):
	if (global):
		pos = tileMap.world_to_map(pos)
	if isAbove:
		pos = Vector2(pos[0], pos[1] + 1)
	var cells = tileMap.get_used_cells()
	var ladders = laddersMap.get_used_cells()
	
#	if (Vector2(pos[0], pos[1] - 1) in cells):
##		If there's a block above the passes one, return null
#		return null
	var results = Vector2(0, 0)
	
#	Checking left
	if Vector2(pos[0] - 1, pos[1] - 1) in cells:
#		if wall
		results[0] = 1
	elif !(Vector2(pos[0] - 1, pos[1]) in cells) and !(Vector2(pos[0] - 1, pos[1]) in ladders):
#		if drop
		results[0] = -1
		
#	Checking right
	if Vector2(pos[0] + 1, pos[1] - 1) in cells:
#		if wall
		results[1] = 1
	elif !(Vector2(pos[0] + 1, pos[1]) in cells) and !(Vector2(pos[0] + 1, pos[1]) in ladders):
#		if drop
		results[1] = -1
	return results

func createPoint(cell):
	var above = Vector2(cell[0], cell[1] - 1)
#	var evenAboveThat = Vector2(cell[0], cell[1] - 2)
	if above in tileMap.get_used_cells():
		return
		
	var pos = tileMap.map_to_world(above) + Vector2(cell_size/2, cell_size/2)
	if graph.get_points() and graph.get_point_position(graph.get_closest_point(pos)) == pos:
		return
	if (showLines):
		var test = TEST.instance()
		test.set_position(pos)
		call_deferred("add_child", test)
	
	graph.add_point(graph.get_available_point_id(), pos)
