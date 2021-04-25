extends TileMap


var targets := []
export (NodePath) var pathFinderPath

var pathFinder
#var CLAY = preload("res://Prefabs/Clay.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pathFinder = get_node(pathFinderPath)

func destroy_block(cell, actual_pos = false):
	if !actual_pos:
		cell = world_to_map(cell)
	if cell in targets:
		targets.erase(cell)
#	If it's clay
	if get_cellv(cell) == 1:
		pass
	set_cellv(cell, -1)
	update_bitmask_area(cell)
#	pathFinder.createMap()
	
	
func target(cell):
	cell = world_to_map(cell)
	var used_cells = get_used_cells()
	var aroundCells = [
	cell - Vector2(1, 0),
	cell + Vector2(1, 0),
	cell - Vector2(0, 1),
	cell + Vector2(0, 1),
	]
	
	var cell_to_use
	for cell in aroundCells:
		if !cell in used_cells:
			cell_to_use = cell
			break
	
	if cell in targets or !(cell in used_cells) or !cell_to_use:
		return false
	
	targets.append(cell)
	
	
	
	return map_to_world(cell_to_use)

func untarget(cell):
	cell = world_to_map(cell)
	if cell in targets:
		targets.erase(cell)
