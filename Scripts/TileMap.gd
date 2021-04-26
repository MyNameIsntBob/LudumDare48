extends TileMap


export (NodePath) var pathFinderPath

var pathFinder

var update_timer := 0.0
var update_after := 0.5
var update_map = false
var CLAY = preload("res://Prefabs/Clay.tscn")

var directions = {
	'up': Vector2(0, -1),
	'down': Vector2(0, 1),
	'left': Vector2(-1, 0),
	'right': Vector2(1, 0),
	'center': Vector2(0, 0)
}

var aroundCells = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pathFinder = get_node(pathFinderPath)
	
	for key in directions:
		var dir = directions[key]
		for key2 in directions:
			var dir2 = directions[key2]
			var newDir = dir + dir2
			for i in range(2):
				if newDir[i] > 1:
					newDir[i] = 1 
				elif newDir[i] < -1:
					newDir[i] = -1
			if ! newDir in aroundCells:
				aroundCells.append(newDir)

func _process(delta):
	if update_map:
		if update_timer <= 0:
			pathFinder.createMap()
			update_map = false
		else:
			update_timer -= delta
	pass

func destroy_block(cell, actual_pos = false):
	if !actual_pos:
		cell = world_to_map(cell)
	if get_cellv(cell) == 5:
		return
		
#	If it's clay
	if get_cellv(cell) == 4:
		var clay = CLAY.instance()
		clay.position = map_to_world(cell) + Vector2(256/2, 256/2)
		get_parent().add_child(clay)
	
	set_cellv(cell, -1)
	update_bitmask_area(cell)
	
	update_pathfinding()
	
func update_pathfinding():
	update_timer = update_after
	update_map = true
	
	
func target(cell, caller_pos):
	cell = world_to_map(cell)
	var used_cells = get_used_cells()
	
	var cell_to_use
	var dist_to_cell
	for dir in aroundCells:
		var current_cell = cell + dir 
		if !current_cell in used_cells:
			var new_cell_dist = map_to_world(current_cell).distance_to(caller_pos)
			if !cell_to_use or new_cell_dist <  dist_to_cell:
				cell_to_use = current_cell
				dist_to_cell = new_cell_dist
				
	if !cell_to_use:
		return false
	
	
	return map_to_world(cell_to_use) + Vector2(256/2, 256/2)

