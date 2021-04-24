extends TileMap


var targets := []
export (NodePath) var pathFinderPath

var pathFinder

# Called when the node enters the scene tree for the first time.
func _ready():
	pathFinder = get_node(pathFinderPath)

func destroy_block(cell):
	if cell in targets:
		targets.erase(cell)
	set_cellv(cell, -1)
	pathFinder.createMap()
	
func target(cell):
	if cell in targets or !(cell in get_used_cells()):
		return false
	
	targets.append(cell)
	
	return true

func untarget(cell):
	if cell in targets:
		targets.erase(cell)
