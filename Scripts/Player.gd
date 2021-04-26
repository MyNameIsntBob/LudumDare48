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

enum Actions {
	MOVE,
	LADDER,
	GOLEM,
	MINE,
	GATHER
}

#[[Actions.MOVE, Vector2(1, 2)], [Actions.LADDER, Vector2(1, 2)], ]
var actionList := []

var selected := false
var path 
var target
var blocksToDestroy := []
var targetBlock 
var targetBlockPos
var cancel := false
var movingTo
var currentAction 

var hasResource = false

var moving = false

var onLadder

var gravity := 1000

var move_speed := 1000

onready var pathFinder = get_parent().find_node("PathFinder")
onready var tilemap = get_parent().find_node("Ground")
onready var ladders = get_parent().find_node("Ladders")

signal here

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Resource.visible = hasResource
	
	if selected:
		$Sprite.modulate = Color(1, 0, 0)
	else:
		$Sprite.modulate = Color(1, 1, 1)
		
	if !moving and !onLadder:
		var below = tilemap.world_to_map(position) + Vector2(0, 1)
		if !(below in tilemap.get_used_cells()) and !(below in ladders.get_used_cells()):
			move_and_slide(Vector2(0, gravity))
			
	if actionList.size() > 0 and !currentAction:
		nextAction()
			
func nextAction():
	currentAction = actionList.pop_front()
	
	if currentAction[0] == Actions.MOVE:
		go_to(currentAction[1])
	elif currentAction[0] == Actions.GATHER:
		gather()
	elif currentAction[0] == Actions.MINE:
		blocksToDestroy = currentAction[1]
		destroy_block()
	elif currentAction[0] == Actions.LADDER:
		pass
	elif currentAction[0] == Actions.GOLEM:
		pass

func cancelActions():
	actionList = []
	path = []
	currentAction = null
	blocksToDestroy = []
	moving = false
	cancel = true
	
func move_to(pos):
	cancel = false
	actionList.append([Actions.MOVE, pos])

func build_ladder(pos):
	cancel = false
	actionList.append([Actions.GATHER])
	actionList.append([Actions.LADDER, pos])

func build_golem(pos):
	cancel = false
	actionList.append([Actions.GATHER])
	actionList.append([Actions.GOLEM, pos])
	actionList.append([Actions.GATHER])
	actionList.append([Actions.GOLEM, pos])

func destroy_blocks(blocks):
	cancel = false
	actionList.append([Actions.MINE, blocks])

func go_to(pos):
	moving = true
	path = pathFinder.findPath(position, pos)
	if !path:
		if currentAction[0] == Actions.MOVE:
			currentAction = null
		return
	movingTo = path[len(path) - 1]
	for character in get_tree().get_nodes_in_group('Selectable'):
		if character.movingTo == movingTo and character != self:
			go_to(path[len(path) - 2])
			return
	next_position()

func gather():
	if hasResource:
		return
	
	var allClay = get_tree().get_nodes_in_group('Clay')
	for clay in allClay:
		var p = pathFinder.findPath(position, clay.position)
		if p.size() != 0:
			go_to(clay.position)
			yield(self, 'here')
			if cancel:
				return
			clay.queue_free()
			hasResource = true
			currentAction = null
			return
	

func destroy_block():
	if cancel:
		return
	
	targetBlock = null
	var blockSize = blocksToDestroy.size()
	if blockSize == 0:
		if currentAction[0] == Actions.MINE:
			currentAction = null
		return
	for block in blocksToDestroy:
		var pos = tilemap.target(block)
		if pos:
			go_to(pos)
			yield(self, 'here')
			if cancel:
				return
			tilemap.destroy_block(block)
			blocksToDestroy.erase(block)

		if block in tilemap.targets:
			blocksToDestroy.erase(block)

	if blockSize == blocksToDestroy.size():
		if currentAction[0] == Actions.MINE:
			currentAction = null
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
	
func next_position():
	print("next_position")
	
	if cancel:
		return
	
	if len(path) > 0:
		target = path.pop_front()
		$Tween.interpolate_property(self, "position", position, target, 1.0 * position.distance_to(target)/move_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.start()
		yield($Tween, "tween_completed")
		if target.x != position.x:
			$Sprite.flip_h = target.x > position.x
		next_position()
	else:
		if currentAction[0] == Actions.MOVE:
			currentAction = null
		emit_signal('here')
		moving =  false
		
func queue_free():
	if targetBlock:
		tilemap.untarget(targetBlock)
	get_parent().unselect(self)
	.queue_free()


func _on_LadderDetector_body_entered(body):
	onLadder = true

func _on_LadderDetector_body_exited(body):
	onLadder = false
