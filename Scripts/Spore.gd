extends KinematicBody2D

var move_by = 100
var up := false

var velocity = Vector2(rand_range(-1.0, 1.0), 0.0)
var speed := 300

var fallBy := 175.0
var fallRange := 75.0

var select_circle = CircleShape2D.new()


#const MUSHROOM = preload("res://Prefabs/Mushroom.tscn")

var mushroomPaths = {
	"Bottom": 'res://Prefabs/Mushrooms/Bottom.tscn',
	"Top": 'res://Prefabs/Mushrooms/Top.tscn',
	"Left": 'res://Prefabs/Mushrooms/Left.tscn',
	"Right": 'res://Prefabs/Mushrooms/Right.tscn',
}

var vectorToDirection = {
	Vector2(1, 0): 'Left',
	Vector2(-1, 0): 'Right',
	Vector2(0, -1): 'Bottom',
	Vector2(0, 1): 'Top'
}

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	_start_tween()
	
	
func _process(delta):
	var collision_info = move_and_collide(velocity.normalized() * delta * speed)
	if collision_info:
		var direction = collision_info.normal
		var collider = collision_info.collider
		if (collider.is_in_group("Selectable")):
			collider.queue_free()
			self.queue_free()
		
		if (collider.is_in_group("Mineable")):
#			print(collision_info.normal)
			var t = Vector2(int(round(direction[0])), int(round(direction[1])))
			if t[0] != 0:
				t[1] = 0
			var MUSHROOM = load(mushroomPaths[vectorToDirection[t]])
			var shroom = MUSHROOM.instance()
			shroom.position = self.position
			find_parent("Master").add_child(shroom)
			self.queue_free()
#		if collision_info.is_in_group
		
		velocity = velocity.bounce(direction)

func _start_tween():
	if up:
		$Tween.interpolate_property(self, "position:y", position.y, position.y - move_by, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	else:
		$Tween.interpolate_property(self, "position:y", position.y, position.y + move_by + rand_range(fallBy - fallRange, fallBy + fallRange) , Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		
	$Tween.start()

func _on_Tween_tween_completed(object, key):
	up = !up
	_start_tween()

