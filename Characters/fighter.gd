class_name Fighter
extends Entity

const SPEED: float = 2.5
const ATTACK_COOLDWON : float = 1.2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var _target : Entity = self

@onready var _nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var _detection: Area3D = $DetectionArea

@export var dmg: int
var _attack_cooldown : float = ATTACK_COOLDWON

var is_skeleton : bool = false

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

const _grave = preload("res://Characters/grave.tscn")


func make_beep():
	if !get_node_or_null("beep"):
		var node = AudioStreamPlayer.new()
		node.name = "beep"
		node.volume_db = -12.0
		add_child(node, true)
	
		var a = AudioStreamWAV.new()
		a.format = AudioStreamWAV.FORMAT_8_BITS
		a.mix_rate =44100
	
		var data = PackedByteArray([])
		var length = a.mix_rate * 0.2  #200ms
		var phase = 0.0
		var DING_FREQUENCY = 800.0  #Windows ding.wav frequency lol
		var increment = 1.0/(a.mix_rate/DING_FREQUENCY)
	
		for i in range(length):
			var percent = i/length
			var LFO = increment*-sin(percent*TAU)*10 + phase
	
			var byte = (128.0*pow(1-percent, 4) * sin(TAU*LFO) ) 
			phase = fmod(phase+increment, 1.0)
			
			data.append( byte )
			
		a.data = data
		node.stream = a 
	
	get_node("beep").play()


func create_grave():
	var grave = _grave.instantiate()
	grave.position = Vector3(global_position.x, 0.0, global_position.z)
	var parent = get_tree().get_nodes_in_group("Allies")[0]
	if (self is Zombie):
		grave.set_type(Grave.GraveType.Skeleton)
	else:
		grave.set_type(Grave.GraveType.Zombie)
	parent.add_child(grave)	
	queue_free()


func has_target() -> bool:
	return not is_same(self, _target)


func find_target() -> void:
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


func death(_dir: Vector3):
	find_target()


func clear_target():
	if _target.on_death.is_connected(death):
		_target.on_death.disconnect(death)
	_target = self
	# Cancel navigation
	_nav_agent.set_target_position(position)


func set_target(target: Entity):
	if is_same(_target, target):
		return
	if _target.on_death.is_connected(death):
		_target.on_death.disconnect(death)
	_target = target
	_target.on_death.connect(death)
	_nav_agent.set_target_position(_target.position)


func _ready() -> void:
	assert(not _nav_agent.avoidance_enabled, "Avoidance requires velocity_computed callback")
	on_death.connect(_fly_away)
	_detection.body_entered.connect(
		func(body: Node3D):
			assert(body is Entity)
			if not has_target() or body.position.distance_squared_to(self.position) < _target.position.distance_squared_to(self.position):
				set_target(body as Entity)
	)

	
func _fly_away(dir: Vector3):
	if is_skeleton:
		queue_free()
		return
	set_collision_mask_value(1, false)
	set_collision_layer_value(2, false)
	set_collision_layer_value(3, false)
	set_collision_layer_value(4, false)
	set_collision_layer_value(10, true)
	set_collision_mask_value(10, true)
	_collision_acceleration = Vector3(0, 0, 0)
	velocity = Vector3(dir.x * 6.0, 4.9, dir.z * 6.0).rotated(Vector3(0.0, 1.0, 0.0), rng.randf_range(-PI / 8, PI / 8))


func _physics_process(delta: float):
	if _target == null:
		return
	if _hp <= 0:
		velocity.y -= gravity * delta
		move_and_slide()
		if is_on_floor():
			create_grave()
		return
		
	_attack_cooldown -= delta
	if has_target():
		var dist : float = _target.position.distance_squared_to(position)
		if dist < 1.5 * 1.5 and _attack_cooldown <= 0.0 :
			# Attack!!!
			_attack_cooldown = ATTACK_COOLDWON
			var dir : Vector3 = (_target.position - position).normalized()
			dir.y = 0
			_target._collision_acceleration = dir * 6
			_collision_acceleration = -dir * 6
			make_beep()
			_target.damage(self.dmg, dir)
			if _target is Fighter:
				_target.find_target()
				_target._attack_cooldown = ATTACK_COOLDWON
				self.damage(_target.dmg, -dir)
				if _hp <= 0:
					return
				if _target is Zombie:
					_target.find_child("*AnimationPlayer").play("Attack")
				elif self is Zombie:
					find_child("*AnimationPlayer").play("Attack")
		else:
			if _nav_agent.is_navigation_finished() and dist < 5.0:
				_nav_agent.set_target_position(_target.position)
			if _target.position.distance_squared_to(position) > 100:
				find_target()
		if _target.position.distance_squared_to(_nav_agent.get_target_position()) > 2.0:
			_nav_agent.set_target_position(_target.position)
		if _nav_agent.is_navigation_finished():
			velocity.x = 0.0
			velocity.z = 0.0
		else:
			var next_path_position: Vector3 = _nav_agent.get_next_path_position()
			velocity = global_position.direction_to(next_path_position) * SPEED
	elif _attack_cooldown <= 0.0:
		if _nav_agent.is_navigation_finished():
			var len = rng.randf_range(3, 10)
			var angle = rng.randf_range(0.0, 2 * PI)
			_nav_agent.set_target_position(position + len * Vector3(sin(angle), 0.0, cos(angle)))
		var next_path_position: Vector3 = _nav_agent.get_next_path_position()
		velocity = global_position.direction_to(next_path_position) * SPEED / 3
	else:
		velocity = Vector3(0, 0, 0)
	
	_finalize_move(delta)
