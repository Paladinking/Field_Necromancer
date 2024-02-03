extends CharacterBody3D


const SPEED = 4.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _target : Node3D = self

@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")

func _ready() -> void:
	$DetectionArea.body_entered.connect(
		func(body: Node3D):
			if is_same(self, _target) or body.position.distance_squared_to(self.position) < _target.position.distance_squared_to(self.position):
				_target = body
				set_movement_target(_target.position)
			
	)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)
	

func _physics_process(delta):
	if not is_same(_target, self) and _target.position.distance_squared_to(navigation_agent.get_target_position()) > 1:
		set_movement_target(_target.position)
	
	if navigation_agent.is_navigation_finished():
		velocity.x = 0.0
		velocity.z = 0.0
		if not is_on_floor():
			velocity.y -= gravity * delta
		move_and_slide()
		return
	
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * SPEED
	
	if not is_on_floor():
		new_velocity.y -= gravity * delta
	
	velocity = new_velocity
	move_and_slide()
