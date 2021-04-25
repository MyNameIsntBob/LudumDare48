extends Node2D

#var dragging = false
var startingPos : Vector2

var dragging = false
var selected = []
var drag_start 
var drag_end 
var select_rect = RectangleShape2D.new()
var mining := false
var building := false
var map_size := 256
var item_id := 0

#func _ready():
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func select_units():
	for item in get_selection():
		if item.collider.is_in_group('Selectable'):
			selected.push_back(item.collider)
			item.collider.selected = true
		else:
			selected.erase(item)
	
func mine_blocks():
	mining = false
	var toMine = []
	for item in get_selection():
		if item.collider.is_in_group('Mineable'):
			toMine.append($Ground.map_to_world(item.metadata))
	for player in selected:
		player.destroy_blocks(toMine)
	
func get_selection():
	select_rect.extents = (drag_end - drag_start) / 2
	var space = get_world_2d().direct_space_state
	var query = Physics2DShapeQueryParameters.new()
	query.set_shape(select_rect)
	query.transform = Transform2D(0, (drag_end + drag_start) / 2)
	drag_start = null
	drag_end = null
	return space.intersect_shape(query)

func _unhandled_input(event):
	
	if building:
		var activeCell = $ToBuild.world_to_map(get_global_mouse_position())
		$ToBuild.set_cellv(activeCell, item_id)
		var cells = $ToBuild.get_used_cells()
		for cell in cells:
			if cell != activeCell:
				$ToBuild.set_cellv(cell, -1)
				
		
		if event.is_action_pressed('select'):
			$Ladders.set_cellv($Ladders.world_to_map(get_global_mouse_position()), item_id)
			for cell in $ToBuild.get_used_cells():
				$ToBuild.set_cellv(cell, -1)
			building = false
			$PathFinder.createMap()
		return
	
	
	if event.is_action_pressed('move_camera'):
		if selected.size() != 0:
#			var tileToDestroy = $Ground.world_to_map(get_global_mouse_position())
#			if tileToDestroy and false:
#				for node in selected:
#					node.block_to_destroy(tileToDestroy)
#			else:
			var space_state = get_world_2d().direct_space_state
			var mpos = get_global_mouse_position()
			var result = space_state.intersect_ray(mpos, Vector2(mpos.x, mpos.y + 1000))
			if (result):
				for node in selected:
					node.blocksToDestroy = []
					node.move_to(result.position)
		else:
			$Camera2D.position = get_global_mouse_position()
		
		
	if event.is_action_pressed('select'):
		if !drag_start:
#			print(selected)
			if selected.size() != 0 and !mining:
				for item in selected:
					item.selected = false
				selected = []
			
			dragging = true
			drag_start = get_global_mouse_position()
			
	if dragging:
		update()
	
	if event.is_action_released('select'):
		if dragging:
			dragging = false
			drag_end = get_global_mouse_position()
			
			if mining:
				mine_blocks()
			else:
				select_units()
			
		
func _draw():
	if dragging:
		draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start), 
			Color(0.5, 0.5, 0.5), false)
			
#	if event is InputEventMouseButton:
#		if event.is_pressed():
#			if !dragging:
#				startingPos = get_global_mouse_position()
#				dragging = true
#		else:
#			dragging = false
#	elif event is InputEventMouseMotion and dragging:
#		$Camera2D.position = startingPos - get_global_mouse_position()




func _on_Button_pressed():
	if selected.size() != 0:
		mining = true


func _on_Build_pressed():
	building = true
