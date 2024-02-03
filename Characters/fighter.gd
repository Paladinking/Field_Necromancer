class_name Fighter
extends Entity

const SPEED: float = 2.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
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

func _physics_process(delta: float):
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
		_finalize_move(delta)
		return
	
	var next_path_position: Vector3 = _nav_agent.get_next_path_position()
	velocity = global_position.direction_to(next_path_position) * SPEED
	_finalize_move(delta)
	
	
