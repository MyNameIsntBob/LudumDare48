extends Position2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


onready var SHROOM = preload('res://Prefabs/Mushrooms/Top.tscn')

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer2_timeout():
	var shroom = SHROOM.instance()
	find_parent("Master").add_child(shroom)
	shroom.position = global_position
	$Timer2.start()
	pass # Replace with function body.
