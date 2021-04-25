extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#var gravity := 20.0
#var velocity : Vector2
#var acceleration := 1500
#var maxSpeed := 100
#var normalFriction := 0.03
#var stoppedFriction := 0.1

#var block_size := 256
#var target_padding := 150

var selected := false
var atTarget := true
var path 
var target
var blocksToDestroy := []
var targetBlock 
var targetBlockPos
var cancel := false
var waitState 
var movingTo

var onLadder

var move_speed := 1000

onready var pathFinder = get_parent().find_node("PathFinder")
onready var tilemap = get_parent().find_node("Ground")

signal here

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if selected:
		$Sprite.modulate = Color(1, 0, 0)
	else:
		$Sprite.modulate = Color(1, 1, 1)
		
	var input_vect = Vector2.ZERO
	
#	if !atTarget and target:
#		if target > position:
#			input_vect.x += 1
#		if target < position: 
#			input_vect.x -= 1
#
##		This is where your issue is located
##		print(abs(position.x - target.x))
#		if position.distance_to(target) < target_padding: #abs(position.x - target.x) < target_padding:
#			next_target()
#		pass
#
#	if blocksToDestroy.size() != 0:
#		if targetBlock:
#			if !targetBlock in blocksToDestroy:
#				tilemap.untarget(targetBlock)
#				targetBlock = null 
#				return
#			if position.distance_to(targetBlockPos) < block_size:
#				destroy_block()
#				blocksToDestroy.erase(targetBlock)
#		else:
#			blocksToDestroy.shuffle()
##	tilemap.map_to_world(targetBlock) + Vector2(block_size/2, block_size/2)
#
#			for block in blocksToDestroy:
#				var pos = tilemap.map_to_world(block) + Vector2(block_size/2, block_size/2)
#				if !block in tilemap.targets:
#					if !targetBlockPos or position.distance_to(targetBlockPos) > position.distance_to(pos):
#						targetBlock = block
#						targetBlockPos = pos
#				else:
#					blocksToDestroy.erase(block)
#			tilemap.target(targetBlock)
#			atTarget = false
#			if targetBlock:
#				move_to(tilemap.map_to_world(targetBlock) + Vector2(block_size/2, block_size/2))
#	elif targetBlock:
#		tilemap.untarget(targetBlock)
#		targetBlock = null

		
#	if !onLadder:
##		if velocity.y < 0:
#			velocity.y = 0
#		velocity.y += gravity
#	else:
#		if target.y < position.y:
#			input_vect.y -= 1
#		elif target.y > position.y:
#			input_vect.y += 1
#
#	if input_vect != Vector2.ZERO:
#		velocity += input_vect * acceleration * delta
##	else:
#	else:
#		velocity = velocity.linear_interpolate(Vector2(0, velocity.y), stoppedFriction)
		
#	velocity = velocity.linear_interpolate(Vector2(0, velocity.y), normalFriction)
	
#	velocity = move_and_slide(velocity)
#func move_to_target():
#	$Tween
#	position = position.linear_interpolate(target, move_speed)

func _unhandled_input(event):
	pass

func cancelActions():
	if !waitState or true:
		return
	cancel = true
	waitState.resume()
	cancel = false

func destroy_blocks(blocks):
	cancelActions()
	blocksToDestroy = blocks
	destroy_block()
			
	pass
	

func destroy_block():
	targetBlock = null
	var blockSize = blocksToDestroy.size()
	if blockSize == 0:
		return
	for block in blocksToDestroy:
		var pos = tilemap.target(block)
		if pos:
			move_to(pos, true)
			waitState = yield(self, 'here')
			if cancel:
				return
			tilemap.destroy_block(block)
			blocksToDestroy.erase(block)
		
		if block in tilemap.targets:
			blocksToDestroy.erase(block)
	
	if blockSize == blocksToDestroy.size():
		return
	
	destroy_block()
#
#	for block in blocksToDestroy:
#		if !closest or position.distance_to(block) < position.distance_to(closest):
#			closest = block
##	Will return a position to move to
#	var pos = tilemap.target(closest)
#	if pos:
#		targetBlock = closest
#		move_to(pos, true)
#		waitState = yield(self, 'here')
#		if cancel:
#			return
#		tilemap.destroy_block(closest)
#		destroy_block()
#		return
#
#	if closest in tilemap.targets:
#		blocksToDestroy.erase(closest)
#	destroy_block()

func move_to(pos, noCancel = false):
	if !noCancel:
		cancelActions()
	path = pathFinder.findPath(position, pos)
	if !path:
		return
	movingTo = path[len(path) - 1]
	for character in get_tree().get_nodes_in_group('Selectable'):
		if character.movingTo == movingTo and character != self:
			move_to(path[len(path) - 2])
			return
	next_target()
	
func next_target():
	if len(path) > 0:
		target = path.pop_front()
		$Tween.interpolate_property(self, "position", position, target, 1.0 * position.distance_to(target)/move_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.start()
		if target.x != position.x:
			$Sprite.flip_h = target.x > position.x
			
		waitState = yield($Tween, 'tween_completed')
		if cancel:
			return
		next_target()
	else:
		emit_signal('here')
		atTarget = true

func _on_Area2D_body_exited(_body):
	onLadder = false


func _on_Area2D_body_entered(_body):
	onLadder = true
