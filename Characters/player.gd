extends Entity


const SPEED = 10.0
const WALK_ANIMATION = "Animation"
const SEND_CHARGE : float = 0.4

var send_cooldown : float = 0.0
var send_time : float = 0.0

func _ready():
	on_death.connect(
		func(_dir: Vector3):
			queue_free()
			#get_tree().quit()
	)
	$necromancer/AnimationPlayer.play(WALK_ANIMATION, -1, 2.0)


func _process(_delta):
	if Input.is_action_just_pressed("attract") and $ZombieFollowArea.has_overlapping_bodies():
		var zombies = $ZombieFollowArea.get_overlapping_bodies()
		for zombie in zombies:
			if zombie is Zombie:
				zombie.set_following(self)
	

	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if look_dir.length_squared() > 0:
		send_time += _delta
		if send_time >= SEND_CHARGE:
			send_time = 0.0
			var zombies = $ZombieFollowArea.get_overlapping_bodies()
			for zombie in zombies:
				if zombie is Zombie and zombie._following_time > 0.0:
					zombie.set_target_location(zombie.position + 50 * Vector3(look_dir.x, 0, look_dir.y))
	else:
		send_time = 0.0
		
	
	if Input.is_action_just_pressed("dig") and $GraveDetectorArea.has_overlapping_bodies():
		var graves = $GraveDetectorArea.get_overlapping_bodies()
		var closest_grave = graves[0]
		for grave in graves:
			if position.distance_squared_to(grave.position) < position.distance_squared_to(closest_grave.position):
				closest_grave = grave
		(closest_grave as Grave).spawn_character()


func _physics_process(delta):
	var input_dir = Input.get_vector("go_left", "go_right", "go_up", "go_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		$necromancer.rotation.y = atan2(direction.x, direction.z) + PI
		$necromancer/AnimationPlayer.play(WALK_ANIMATION, -1, 2.0)
	else:
		$necromancer/AnimationPlayer.pause()
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	_finalize_move(delta)

