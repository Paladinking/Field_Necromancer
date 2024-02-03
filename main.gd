extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	$Grave.raise()
	$Grave.creature_to_spawn = preload("res://Characters/zombie.tscn")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _unhandled_key_input(event):
	if event.keycode == KEY_ESCAPE:
		get_tree().quit()