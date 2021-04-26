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
func _process(_delta):
	if selected:
		$Sprite.modulate = Color(1, 0, 0)
	else:
		$Sprite.modulate = Color(1, 1, 1)

#func cancelActions():
#	return
#	if !waitState:
#		return
#	cancel = true
#	waitState.resume()
#	cancel = false

func destroy_blocks(blocks):
#	cancelActions()
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
#	if !noCancel:
#		cancelActions()
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
#		atTarget = true
		
func queue_free():
	if targetBlock:
		tilemap.untarget(targetBlock)
	get_parent().unselect(self)
	.queue_free()

func _on_Area2D_body_exited(_body):
	onLadder = false


func _on_Area2D_body_entered(_body):
	onLadder = true
