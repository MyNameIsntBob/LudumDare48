extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var score = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$GameOver.visible = get_tree().get_nodes_in_group('Selectable').size() == 0
	
func _on_Restart_pressed():
	get_tree().reload_current_scene()

func _on_Finish_body_entered(body):
	score = get_tree().get_nodes_in_group('Selectable').size()
	$Finished.show()
	$Finished.find_node("Score").text = "Score: " + str(score)
	
