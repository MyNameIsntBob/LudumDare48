extends Node2D


var explode_range := 500

var select_circle = CircleShape2D.new()

func _ready():
	select_circle.radius = explode_range
	

func explode():
	var space = get_world_2d().direct_space_state
	var query = Physics2DShapeQueryParameters.new()
	query.set_shape(select_circle)
	query.transform = Transform2D(0, global_position)
	var objects = space.intersect_shape(query)
	
	for collision in objects:
		if collision.collider is TileMap:
			collision.collider.destroy_block(collision.metadata, true)
		else:
			collision.collider.queue_free()

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()


func _on_Timer_timeout():
	explode()
