extends CharacterBody3D


const SPEED = 2.5
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _target : Node3D = self

@onready var _nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var _detection: Area3D = $DetectionArea

func has_target() -> bool:
	return not is_same(self, _target)

func clear_target():
	_target = self

func _ready() -> void:
	assert(not _nav_agent.avoidance_enabled, "Avoidance requires velocity_computed callback")
	_detection.body_entered.connect(
		func(body: Node3D):
			if not has_target() or body.position.distance_squared_to(self.position) < _target.position.distance_squared_to(self.position):
				_target = body
				_nav_agent.set_target_position(_target.position)
			
	)


func _physics_process(delta):
	if has_target():
		if _target.position.distance_squared_to(position) > 400:
			var _potential_targets = _detection.get_overlapping_bodies()
			if not _potential_targets:
				clear_target()
			else:
				_target = _potential_targets.reduce(func(cur : Node3D, n: Node3D):
					return n if n.position.distance_squared_to(position) < cur.position.distance_squared_to(position) else cur, 
					_potential_targets[0]
				)
			
		if _target.position.distance_squared_to(_nav_agent.get_target_position()) > 1:
			_nav_agent.set_target_position(_target.position)
	
	if _nav_agent.is_navigation_finished():
		velocity.x = 0.0
		velocity.z = 0.0
		if not is_on_floor():
			velocity.y -= gravity * delta
		move_and_slide()
		return
	
	var next_path_position: Vector3 = _nav_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * SPEED
	
	if not is_on_floor():
		new_velocity.y -= gravity * delta
	
	velocity = new_velocity
	move_and_slide()
