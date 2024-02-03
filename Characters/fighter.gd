class_name Fighter
extends Entity

const SPEED: float = 2.5
const ATTACK_COOLDWON : float = 1.2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var _target : Entity = self

@onready var _nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var _detection: Area3D = $DetectionArea

@export var dmg: int
var _attack_cooldown : float = 0.0

func has_target() -> bool:
	return not is_same(self, _target)

func find_target():
	var potential_targets: Array[Node3D] = _detection.get_overlapping_bodies()\
		.filter(func(e: Node3D): return e is Entity and e._hp > 0)
	if not potential_targets:
		clear_target()
	else:
		var nearest: Node3D = potential_targets[0]
		var dist : float = nearest.position.distance_squared_to(position)
		for entity in potential_targets.slice(1):
			var new_dist : float = entity.position.distance_squared_to(position)
			if new_dist < dist:
				nearest = entity
				dist = new_dist
		set_target(nearest as Entity)

func clear_target():
	if _target.on_death.is_connected(find_target):
		_target.on_death.disconnect(find_target)
	_target = self
	# Cancel navigation
	_nav_agent.set_target_position(position)

func set_target(target: Entity):
	if _target.on_death.is_connected(find_target):
		_target.on_death.disconnect(find_target)
	_target = target
	_target.on_death.connect(find_target)
	_nav_agent.set_target_position(_target.position)

func _ready() -> void:
	assert(not _nav_agent.avoidance_enabled, "Avoidance requires velocity_computed callback")
	_detection.body_entered.connect(
		func(body: Node3D):
			assert(body is Entity)
			if not has_target() or body.position.distance_squared_to(self.position) < _target.position.distance_squared_to(self.position):
				set_target(body as Entity)
	)

func _physics_process(delta: float):
	_attack_cooldown -= delta
	if has_target():
		var dist : float = _target.position.distance_squared_to(position)
		if dist < 1.5 * 1.5 and _attack_cooldown <= 0.0 :
			# Attack!!!
			_attack_cooldown = ATTACK_COOLDWON
			var dir : Vector3 = (_target.position - position).normalized()
			dir.y = 0
			_target._collision_acceleration += dir * 6
			_collision_acceleration -= dir * 6
			_target.damage(self.dmg)
			if _target is Fighter:
				self.damage(_target.dmg)
		else:
			if _nav_agent.is_navigation_finished() and dist < 5.0:
				_nav_agent.set_target_position(_target.position)
			if _target.position.distance_squared_to(position) > 400:
				find_target()
		if _target.position.distance_squared_to(_nav_agent.get_target_position()) > 2.0:
			_nav_agent.set_target_position(_target.position)
	
	if _nav_agent.is_navigation_finished():
		velocity.x = 0.0
		velocity.z = 0.0
	else:
		var next_path_position: Vector3 = _nav_agent.get_next_path_position()
		velocity = global_position.direction_to(next_path_position) * SPEED
	_finalize_move(delta)
	
	
