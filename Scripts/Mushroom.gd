extends StaticBody2D

const SPORE = preload("res://Prefabs/Spore.tscn")

var spawnTime = 8.0
var spawnVar = 2.0

func spawnSpore():
	$AnimationPlayer.play("shootSpore")
	yield($AnimationPlayer, 'animation_finished')
	var spore = SPORE.instance()
	spore.position = $Position2D.global_position
	find_parent("Master").add_child(spore)
	


func _on_Timer_timeout():
	spawnSpore()
	$Timer.wait_time = rand_range(spawnTime - spawnVar, spawnTime + spawnVar)
	$Timer.start()
