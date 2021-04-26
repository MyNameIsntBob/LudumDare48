extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var break_id = 7

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var blocksToDestroy = []
	for node in get_tree().get_nodes_in_group('Selectable'):
		for block in node.blocksToDestroy:
			blocksToDestroy.append(world_to_map(block))
			
	for cell in get_used_cells():
		if !cell in blocksToDestroy:
			set_cellv(cell, -1) 
	
	for cell in blocksToDestroy:
		set_cellv(cell, break_id)
	pass
