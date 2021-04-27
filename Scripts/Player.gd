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

var loopCount := 0

var mineTime := 2.0

export var halfBuilt = true

var hasResource = false

var moving = false

var onLadder

const gravity := 1000

const move_speed := 1000

onready var pathFinder = get_parent().find_node("PathFinder")
onready var tilemap = get_parent().find_node("Ground")
onready var ladders = get_parent().find_node("Ladders")
onready var toBuild = get_parent().find_node("ToBuild")

const golem_path = 'res://Prefabs/Characters/Player.tscn'

signal here

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if moving:
		if $AnimationPlayer.current_animation != 'Walk':
			$AnimationPlayer.stop()
			$AnimationPlayer.play("Walk")
	else:
		if $AnimationPlayer.current_animation == 'Walk':
			$AnimationPlayer.stop()
		$Full.frame = 0
	
	if halfBuilt:
		$Half.visible = true
		$Full.visible = false
		selected = false
		cancelActions()
		return
	else:
		$Half.visible = false
		$Full.visible = true
	
	$Resource.visible = hasResource
	
	if selected:
		$Full.modulate = Color(1, 0, 0)
	else:
		$Full.modulate = Color(1, 1, 1)
		
	if !moving and !onLadder:
		var below = tilemap.world_to_map(position + Vector2(0, 256/2))
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
		ladder()
	elif currentAction[0] == Actions.GOLEM:
		golem()

func cancelActions():
	if actionList.size() != 0:
		for action in actionList:
			if action[0] == Actions.LADDER:
				removeToBuild(action[1])
			if action[0] == Actions.GOLEM:
				removeToBuild(action[1] - Vector2(0, 256))
		actionList = []
	path = []
	currentAction = null
	blocksToDestroy = []
	moving = false
	cancel = true
	emit_signal('here')
	
func move_to(pos):
	cancel = false
	actionList.append([Actions.MOVE, pos])

func gather_orb():
	cancel = false
	actionList.append([Actions.GATHER])

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

func go_to(pos, ignoreStack = false):
	moving = true
	path = pathFinder.findPath(position, pos)
	if !path or position == pos:
		if currentAction[0] == Actions.MOVE:
			currentAction = null
		moving = false
		emit_signal('here')
		loopCount = 0
		return
	movingTo = path[len(path) - 1]
	for character in get_tree().get_nodes_in_group('Selectable'):
		if !ignoreStack and loopCount < 10 and character != self and character.movingTo == movingTo and character != self:
			loopCount += 1
			go_to(path[len(path) - 2])
			return
	loopCount = 0
	next_position()
	

func gather():
	if hasResource:
		currentAction = null
		return
	
	var allClay = get_tree().get_nodes_in_group('Clay')
	for clay in allClay:
		var p = pathFinder.findPath(position, clay.position)
		if p.size() != 0:
			go_to(clay.position, true)
			yield(self, 'here')
			if cancel:
				return
			clay.queue_free()
			hasResource = true
			currentAction = null
			return
	currentAction = null

func ladder():
	if !hasResource:
		removeToBuild(currentAction[1])
		currentAction = null
		return
		
	go_to(currentAction[1], true)
	yield(self, 'here')
	if cancel:
		return
	var cell = ladders.world_to_map(currentAction[1])
	hasResource = false
	ladders.set_cellv(cell, 0)
	removeToBuild(currentAction[1])
	currentAction = null
	pathFinder.createMap()
		
func golem():
	if !hasResource:
		removeToBuild(currentAction[1] - Vector2(0, 256))
		currentAction = null
		return
	
	go_to(currentAction[1], true)
	yield(self, 'here')
	if cancel:
		return
	hasResource = false
	removeToBuild(currentAction[1] - Vector2(0, 256))
	for node in get_tree().get_nodes_in_group('Selectable'):
		if node.halfBuilt and node.position == currentAction[1]:
			node.halfBuilt = false
			currentAction = null
			return
	var golem = load(golem_path).instance()
	golem.position = currentAction[1]
	get_parent().add_child(golem)
	currentAction = null

func removeToBuild(pos):
	var cell = ladders.world_to_map(pos)
	toBuild.set_cellv(cell, -1)
	

func destroy_block():
	
	if cancel:
		return
		
	var first = true
		
	var cells = tilemap.get_used_cells()
	
	targetBlock = null
	var blockSize = blocksToDestroy.size()
	if blockSize == 0:
		if currentAction and currentAction[0] == Actions.MINE:
			currentAction = null
		return

	for block in blocksToDestroy:
		if !targetBlock:
			var skip = false
			if !tilemap.world_to_map(block) in cells:
				skip = true 
				
			for character in get_tree().get_nodes_in_group('Selectable'):
				if block == character.targetBlock:
					skip = true
			if !skip:
				var pos = tilemap.target(block, position)
				if pos:
					path = pathFinder.findPath(position, pos)
					if len(path) != 0:
						targetBlock = block
			else:
				blocksToDestroy.erase(block)
	
	if targetBlock and first:
		first = false
		moving = true
		movingTo = path[len(path) - 1]
		next_position()
		yield(self, 'here')
		if cancel:
			return
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Mine")
		$LoadingBar.start_loading(mineTime)
		yield($LoadingBar, 'finished')
		tilemap.destroy_block(targetBlock)
		targetBlock = null
		blocksToDestroy.erase(targetBlock)
		destroy_block()

	if !targetBlock or blockSize == blocksToDestroy.size():
		if currentAction and currentAction[0] == Actions.MINE:
			currentAction = null
		return

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
	
	if cancel:
		return
		
	if len(path) > 0:
		target = path.pop_front()
		$Tween.interpolate_property(self, "position", position, target, 1.0 * position.distance_to(target)/move_speed, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		$Tween.start()
		if target.x != position.x:
			$Full.flip_h = target.x > position.x
		yield($Tween, "tween_completed")
		next_position()
	else:
		if currentAction and currentAction[0] == Actions.MOVE:
			currentAction = null
		emit_signal('here')
		moving =  false
		
func queue_free():
	get_parent().unselect(self)
	.queue_free()


func _on_LadderDetector_body_entered(body):
	onLadder = true

func _on_LadderDetector_body_exited(body):
	onLadder = false

