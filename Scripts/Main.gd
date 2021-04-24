extends Node2D

#var dragging = false
var startingPos : Vector2

var dragging = false
var selected = []
var drag_start : Vector2
var select_rect = RectangleShape2D.new()

func _process(delta):
	pass
#	update()
#	if dragging:
#		print('dragging')
#		print(drag_start)

func select_units():
	pass

func _unhandled_input(event):
	if event.is_action_pressed('move_camera'):
		$Camera2D.position = get_global_mouse_position()
		
		
	if event.is_action_pressed('select'):
		if !dragging:
			dragging = true
			drag_start = get_global_mouse_position()
	
	if dragging:
		update()
	
	if event.is_action_released('select'):
		if dragging:
			dragging = false
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
