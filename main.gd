extends Node

const CAMERA_OFFSET = Vector3(0, 100, 42)


# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
	$Grave.raise(0)
	$Grave.creature_to_spawn = preload("res://Characters/zombie.tscn")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Camera3D.position = $Player.position + CAMERA_OFFSET + $Player.camera_offset


func _unhandled_key_input(event):
	if event.keycode == KEY_ESCAPE:
		get_tree().quit()
