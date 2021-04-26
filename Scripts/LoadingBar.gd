extends TextureProgress

var loading = false
var count = 0.0
var countTo = 0

signal finished

func _process(delta):
	value = count
	max_value = countTo
	if loading:
		visible = true
		count += delta
		if countTo <= count:
			loading = false
			emit_signal("finished")
	else:
		count = 0.0
		var countTo = 0
		visible = false

func start_loading(amount):
	countTo = amount
	loading = true
