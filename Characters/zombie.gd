extends Fighter

const FOLLOW_TIME : float = 5.0
const WALKING_ANIMATION = "March"

# Player or null
var _following_time: float = 0.0
var _following: Node3D

var _has_target_location : bool = false



func set_target_location(pos: Vector3):
	_nav_agent.set_target_position(pos)
	_has_target_location = true
	_following_time = FOLLOW_TIME


func set_following(goal: Node3D):
	_following = goal
	_following_time = FOLLOW_TIME
	_nav_agent.set_target_position(_following.position)
	_has_target_location = false


func _ready():
	super._ready()
	$AgressiveArea.body_entered.connect(
		func(node : Node3D):
			_has_target_location = false
			_following_time = 0.0
			find_target()
	)


func _physics_process(delta: float):
	if _following_time > 0.0:
		_following_time -= delta
		if _has_target_location:
			if _nav_agent.is_navigation_finished():
				_has_target_location = false
				_following_time = 0.0
		elif _following.position.distance_squared_to(_nav_agent.get_target_position()) > 2.0:
			_nav_agent.set_target_position(_following.position)
		var next_path_position: Vector3 = _nav_agent.get_next_path_position()
		velocity = global_position.direction_to(next_path_position) * SPEED
		_finalize_move(delta)
		if not $zombie/AnimationPlayer.is_playing() and not velocity.is_zero_approx():
			$zombie/AnimationPlayer.play(WALKING_ANIMATION)
		elif $zombie/AnimationPlayer.assigned_animation == WALKING_ANIMATION and $zombie/AnimationPlayer.is_playing():
			$zombie/AnimationPlayer.pause()
	else:
		super._physics_process(delta)
