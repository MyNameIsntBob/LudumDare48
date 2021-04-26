extends StaticBody2D

var noExplode = false
export (Vector2) var direction

const SPORE = preload("res://Prefabs/Spore.tscn")

var EXPLOSION = preload("res://Prefabs/Explosion.tscn")

var spawnTime = 3.0
var spawnVar = 1.0

var number_to_spawn := 3
var number_spawned := 0

func _ready():
	var tileMap = find_parent("Master").find_node("Ground")
	var tileOn = tileMap.world_to_map(position) + direction
	if tileMap.get_cellv(tileOn) == 5:
		print("No break")
		noExplode = true


func spawnSpore():
	$AnimationPlayer.play("shootSpore")
	yield($AnimationPlayer, 'animation_finished')
	var spore = SPORE.instance()
	spore.position = $Position2D.global_position
	find_parent("Master").add_child(spore)


func explode():
	var ep = EXPLOSION.instance()
	ep.position = position
	get_parent().add_child(ep)

func _on_Timer_timeout():
	spawnSpore()
	number_spawned += 1
	if number_spawned >= number_to_spawn and !noExplode:
		explode()
		return
	$Timer.wait_time = rand_range(spawnTime - spawnVar, spawnTime + spawnVar)
	$Timer.start()
