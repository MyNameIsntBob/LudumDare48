extends Node2D

#var dragging = false
var startingPos : Vector2

var dragging = false
var selected = []
var drag_start 
var drag_end 
var select_rect = RectangleShape2D.new()
var mine := false

var blocksToMine := []

func select_units():
	select_rect.extents = (drag_end - drag_start) / 2
	var space = get_world_2d().direct_space_state
	var query = Physics2DShapeQueryParameters.new()
	query.set_shape(select_rect)
	query.transform = Transform2D(0, (drag_end + drag_start) / 2)
	var to_select = space.intersect_shape(query)
	print(to_select)
	for item in to_select:
		if item.collider.is_in_group('Selectable'):
			selected.push_back(item.collider)
			item.collider.selected = true
		else:
			selected.erase(item)
	drag_start = null
	drag_end = null

func _unhandled_input(event):
	if event.is_action_pressed('move_camera'):
		var tileToDestroy = $Ground.world_to_map(get_global_mouse_position())
		if tileToDestroy and false:
			for node in selected:
				node.block_to_destroy(tileToDestroy)
		else:
			var space_state = get_world_2d().direct_space_state
			var mpos = get_global_mouse_position()
			var result = space_state.intersect_ray(mpos, Vector2(mpos.x, mpos.y + 1000))
			if (result):
				for node in selected:
					node.move_to(result.position)
			pass
#		$Camera2D.position = get_global_mouse_position()
		
		
	if event.is_action_pressed('select'):
		if !drag_start:
#			print(selected)
			if selected.size() != 0:
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
			
#			print(selected)
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




func _on_Player_destroyTile(cell):
	$TileMap.set_cellv(cell, -1)
	$PathFinder.createMap()
	pass # Replace with function body.


func _on_Button_pressed():
	mine = true
