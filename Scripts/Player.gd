extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var selected := false
var gravity := 10.0
var velocity : Vector2
var target : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if selected:
		$Sprite.modulate = Color(1, 0, 0)
	else:
		$Sprite.modulate = Color(1, 1, 1)
	velocity.y += gravity
	velocity = move_and_slide(velocity)
	pass
