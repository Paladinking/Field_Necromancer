extends Entity


const SPEED = 10.0
const MAX_LOOK_DISTANCE = 10.0
const WALK_ANIMATION = "Animation"

var camera_offset = Vector3.ZERO


func _ready():
	on_death.connect(
		func(_dir: Vector3):
			queue_free()
			get_tree().quit()
	)
	$necromancer/AnimationPlayer.play(WALK_ANIMATION)
	$necromancer/AnimationPlayer.pause()


func _process(_delta):
	if Input.is_action_just_pressed("dig") and $GraveDetectorArea.has_overlapping_bodies():
		var graves = $GraveDetectorArea.get_overlapping_bodies()
		var closest_grave = graves[0]
		for grave in graves:
			if position.distance_squared_to(grave.position) < position.distance_squared_to(closest_grave.position):
				closest_grave = grave
		closest_grave.spawn_character()
	#camera_offset = camera_offset.clamp(target, target)


func _physics_process(delta):
	var input_dir = Input.get_vector("go_left", "go_right", "go_up", "go_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		$necromancer.rotation.y = atan2(direction.x, direction.z) + PI
		$necromancer/AnimationPlayer.play(WALK_ANIMATION)
	else:
		$necromancer/AnimationPlayer.pause()
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	_finalize_move(delta)

	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	var target = transform.basis * Vector3(look_dir.x, 0, look_dir.y) * MAX_LOOK_DISTANCE
	camera_offset += (target - camera_offset) / 15


func on_grave_detected(body: Node3D):
	print("grave deteced!")
