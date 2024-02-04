extends Node

const STATIC_CAMERA_OFFSET = Vector3(0, 100, 42)
const MAX_LOOK_DISTANCE = 10.0

var player_alive : bool = true
var camera_offset : Vector3 = Vector3.ZERO
var player_position : Vector3 = Vector3.ZERO
var enemy_targets : int


# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/Victory.visible = false
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
	$Player.on_death.connect(
		func(_dir : Vector3):
			player_alive = false
			print("player died!")
	)
	$Player.position = $World/PlayerSpawn.position
	var enemy_parent = $Enemies
	enemy_targets = 0
	for enemy in find_children("Fighter*"):
		if (enemy as Fighter).is_mission_target:
			enemy_targets += 1
			(enemy as Fighter).on_death.connect(
				func(_dir : Vector3):
					enemy_targets -= 1
					if enemy_targets == 0:
						_display_victory()
			)
		if enemy.get_parent() != enemy_parent:
			enemy.reparent(enemy_parent)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player_alive:
		player_position = $Player.position

	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	var target = Vector3(look_dir.x, 0, look_dir.y) * MAX_LOOK_DISTANCE
	camera_offset += (target - camera_offset) / 15

	$Camera3D.position = STATIC_CAMERA_OFFSET + camera_offset + player_position


func _display_victory():
	$CanvasLayer/Victory.visible = true
	print("You win!!!!!")


func _unhandled_key_input(event):
	if event.keycode == KEY_ESCAPE:
		get_tree().quit()
