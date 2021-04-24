extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var gravity := 20.0
var velocity : Vector2
var acceleration := 1500
var maxSpeed := 100
var normalFriction := 0.03
var stoppedFriction := 0.1

var target_padding := 100

var selected := false
var atTarget := true
var path 
var target
var blockToDestroy

var onLadder

onready var pathFinder = get_parent().find_node("PathFinder")

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
#		print(abs(position.x - target.x))
		if position.distance_to(target) < target_padding: #abs(position.x - target.x) < target_padding:
			next_target()
		pass
	elif blockToDestroy:
		destroy_block()
		
	if !onLadder:
		if velocity.y < 0:
			velocity.y = 0
		velocity.y += gravity
	else:
		if target.y < position.y:
			input_vect.y -= 1
		elif target.y > position.y:
			input_vect.y += 1
			
	if input_vect != Vector2.ZERO:
		velocity += input_vect * acceleration * delta
#	else:
	else:
		velocity = velocity.linear_interpolate(Vector2(0, velocity.y), stoppedFriction)
		
	velocity = velocity.linear_interpolate(Vector2(0, velocity.y), normalFriction)
	
	velocity = move_and_slide(velocity)

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
#		if target == null:
#			jump()
#			next_target()
	else:
		atTarget = true
		
	
func block_to_destroy(pos):
	blockToDestroy = pos
#	move_to(tileMap.map_to_world(pos))


func _on_Area2D_body_exited(_body):
	onLadder = false


func _on_Area2D_body_entered(_body):
	onLadder = true
