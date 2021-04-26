extends Camera2D


var speed = 40

var moving = false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if moving:
		position.y += speed * delta
	pass


func _on_Timer_timeout():
	moving = true


func _on_Area2D_body_entered(body):
	body.queue_free()
