extends Node2D

export var cell_size = 256

export (NodePath) var tileMapPath
export (NodePath) var laddersMapPath

var first = false

var tileMap
var laddersMap
var graph 

var used_cells
var used_ladders

var direction = {
	"up": Vector2(0, -1),
	"down": Vector2(0, 1),
	"left": Vector2(-1, 0),
	"right": Vector2(1, 0)
} 

#var thread
var updating := false
var updateAfterThis := false

var showLines = false

onready var topLeft = get_parent().find_node("TopLeft")
onready var bottomRight = get_parent().find_node("BottomRight")

const TEST = preload("res://Prefabs/Face.tscn")


func _ready():
	graph = AStar2D.new()
	tileMap = get_node(tileMapPath)
	laddersMap = get_node(laddersMapPath)
#	thread = Thread.new()
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
#	var used_cells = get_cells_in_area(tileMap)

	var points = graph.get_points()
	for point in points:
		var pos = graph.get_point_position(point)
		var onGround = (tileMap.world_to_map(pos) + direction["down"]) in used_cells
		var closestRight = -1
		var closestBelow = -1
		var stat = cellType(pos, true, true)

		var pointsToJoin = []
		var noBiJoin = []

		for newPoint in points:
			var newPos = graph.get_point_position(newPoint)
			
			if newPos[0] == pos[0] or newPos[1] == pos[1]:
				if (newPos[0] == pos[0] + cell_size and newPos[1] == pos[1]):
					closestRight = newPoint

				if !onGround and newPos[0] == pos[0] and newPos[1] > pos[1]:
					if closestBelow < 0 or newPos[1] < graph.get_point_position(closestBelow)[1]:
						closestBelow = newPoint

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
#	update()
#	BuildMap()
#
#func _draw():
#	if !showLines:
#		return
#
##	var used_cells = get_cells_in_area(tileMap)
#
#	var points = graph.get_points()
#	for point in points:
#		var pos = graph.get_point_position(point)
#		var onGround = (tileMap.world_to_map(pos) + direction["down"]) in used_cells
#		var closestRight = -1
#		var closestBelow = -1
#		var stat = cellType(pos, true, true)
#
#		var pointsToJoin = []
#		var noBiJoin = []
#
#		for newPoint in points:
#			var newPos = graph.get_point_position(newPoint)
#
#			if newPos[0] == pos[0] or newPos[1] == pos[1]:
#				if pos + (direction["right"] * cell_size) == newPos:
##				if (newPos[0] == pos[0] + cell_size and newPos[1] == pos[1]):
#					closestRight = newPoint
#
#				if !onGround and newPos[0] == pos[0] and newPos[1] > pos[1]:
#					if closestBelow < 0 or newPos[1] < graph.get_point_position(closestBelow)[1]:
#						closestBelow = newPoint
#
#		if (closestBelow > 0):
#			if (graph.get_point_position(closestBelow)[1] == pos[1] + cell_size):
#				pointsToJoin.append(closestBelow)
#			else:
#				noBiJoin.append(closestBelow)
#
#		if (closestRight > 0):
#			pointsToJoin.append(closestRight)
#
#
#		for joinPoint in pointsToJoin:
#			draw_line(pos, graph.get_point_position(joinPoint), Color(255, 0, 0), 1)
#		for joinPoint in noBiJoin:
#			draw_line(pos, graph.get_point_position(joinPoint), Color(255, 0, 0), 1)

#func updateMap(cell):
#	var cells = tileMap.get_used_cells()
#	var ladders = laddersMap.get_used_cells()
#
#	tileMap.map_to_world()
#
#
#	pass

func get_cells_in_area(tm):
	var cur_top_left = tm.world_to_map(topLeft.global_position) 
	var cur_bottom_right = tm.world_to_map(bottomRight.global_position)
	var cells = []
	
	for cell in tm.get_used_cells():
		if (cell[0] > cur_top_left[0] and cell[0] < cur_bottom_right[0] and
			cell[1] > cur_top_left[1] and cell[1] < cur_bottom_right[1]):
			cells.append(cell)
	return cells

func createMap():	
	
#	if updating:
#		createConections()
#		return

#	updating = true
#	Reset if you already created the map
	graph.clear() 
	for node in get_children():
		remove_child(node)
		node.queue_free()
	
#	var space_state = get_world_2d().direct_space_state
	used_cells = get_cells_in_area(tileMap)
	
	used_ladders = get_cells_in_area(laddersMap)
	
	for cell in used_ladders:
		createPoint(cell)
		createPoint(cell + direction["down"])
	
	for cell in used_cells:
		var above = cell + direction["up"]
	#	var evenAboveThat = Vector2(cell[0], cell[1] - 2)
		if !above in used_cells:
			createPoint(cell)
			var stat = cellType(cell)
			
			if !cell + direction["left"] in used_cells:
				createPoint(cell + direction["left"])
				pass
			if stat[1] == -1:
				createPoint(cell + direction["right"])
				pass
	createConections()

func cellType(pos, global = false, isAbove = false):
	if (global):
		pos = tileMap.world_to_map(pos)
	if isAbove:
		pos += direction['down']
#		pos = Vector2(pos[0], pos[1] + 1)
#	var cells = get_cells_in_area(tileMap)
#	var ladders = get_cells_in_area(laddersMap)
	
	if (pos + direction["up"] in used_cells):
#		If there's a block above the passes one, return null
		return null
	var results = Vector2(0, 0)
	
#	Checking left
	if pos + direction["left"] + direction["up"] in used_cells:
#		if wall
		results[0] = 1
	elif !(pos + direction["left"] in used_cells) and !(pos + direction["left"]in used_ladders):
#		if drop
		results[0] = -1
		
#	Checking right
	if pos + direction["right"] + direction["up"] in used_cells:
#		if wall
		results[1] = 1
	elif !(pos + direction["right"] in used_cells) and !(pos + direction['right'] in used_ladders):
#		if drop
		results[1] = -1
	return results

func createPoint(cell):
	var above = cell + direction["up"]
	var evenAboveThat = above + direction["up"]
#	var allCells = get_cells_in_area(tileMap)
	if above in used_cells or evenAboveThat in used_cells:
		return
		
	var pos = tileMap.map_to_world(above) + Vector2(cell_size/2, cell_size/2)
	if graph.get_points() and graph.get_point_position(graph.get_closest_point(pos)) == pos:
		return
	if (showLines):
		var test = TEST.instance()
		test.set_position(pos)
		call_deferred("add_child", test)
	
	graph.add_point(graph.get_available_point_id(), pos)
