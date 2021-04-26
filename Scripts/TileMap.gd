extends TileMap


var targets := []
export (NodePath) var pathFinderPath

var pathFinder

var update_timer := 0.0
var update_after := 0.5
var update_map = false
var CLAY = preload("res://Prefabs/Clay.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pathFinder = get_node(pathFinderPath)

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
	if cell in targets:
		targets.erase(cell)
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
