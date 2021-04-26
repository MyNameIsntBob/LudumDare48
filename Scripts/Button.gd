extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var normal = 98
var hover = 87
var pressed = 77

var isOver := false
var isPressed := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isPressed:
		frame = pressed
	elif isOver:
		frame = hover
	else:
		frame = normal

func _on_mouse_entered():
	isOver = true


func _on_mouse_exited():
	isOver = false


func _on_button_up():
	isPressed = false
	

func _on_button_down():
	isPressed = true

