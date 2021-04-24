extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var gravity := 10.0
var velocity : Vector2
var jumpForce := 100
var acceleration := 1500
var maxSpeed := 100
var friction := 0.2

var target_padding := 1

var selected := false
var atTarget := true
var path 
var target
var blockToDestroy

onready var pathFinder = get_parent().find_node("PathFinder")
onready var tileMap = get_parent().find_node("TileMap")

signal destroyTile(cell)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if selected:
		$Sprite.modulate = Color(1, 0, 0)
	else:
		$Sprite.modulate = Color(1, 1, 1)
		
	var input_vect = Vector2.ZERO
	
	
	if !atTarget:
		if target > position:
			input_vect.x += 1
		if target < position: 
			input_vect.x -= 1
			
#		This is where your issue is located
		if position.x - target.x < target_padding:
			next_target()
		pass
	elif blockToDestroy:
		destroy_block()
		
	if input_vect != Vector2.ZERO:
		velocity += input_vect * acceleration * delta
	else:
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)


	velocity.y += gravity
	velocity = move_and_slide(velocity)

func jump():
	velocity.y = -jumpForce

func destroy_block():
	emit_signal("destroyTile", blockToDestroy)
	blockToDestroy = null

func move_to(pos):
	atTarget = false
	path = pathFinder.findPath(position, pos)
	next_target()
	
func next_target():
	if len(path) > 0:
		target = path.pop_front()
		if target == null:
			jump()
			next_target()
	else:
		atTarget = true
		
	
func block_to_destroy(pos):
	blockToDestroy = pos
	move_to(tileMap.map_to_world(pos))
