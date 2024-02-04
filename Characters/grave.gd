class_name Grave
extends AnimatableBody3D


const RAISE_VELOCITY = 5

var velocity : float
var target_height : float
var start_height : float

var creature_to_spawn


func _ready():
	velocity = 0.0
	if position.y == 0:
		start_height = -5.0
	else:
		start_height = position.y


func _physics_process(delta):
	if not abs(velocity) < 0.01:
		move_and_collide(Vector3(0, velocity, 0) * delta)
		if $CreatureHolder.get_child_count() > 0:
			$CreatureHolder.get_child(0).position += Vector3(0, -velocity, 0) * delta

		if abs(position.y - target_height) < 0.1:
			velocity = 0
			position.y = target_height

			if $CreatureHolder.get_child_count() > 0:
				var child = $CreatureHolder.get_child(0)
				child.process_mode = PROCESS_MODE_INHERIT
				var parent = get_tree().get_nodes_in_group("Allies")[0]
				child.reparent(parent)

				queue_free()


func raise(ground_height : float = 0.0):
	velocity = RAISE_VELOCITY
	target_height = ground_height

enum GraveType {Zombie, Skeleton}

func set_type(type : GraveType = GraveType.Zombie):
	match type:
		GraveType.Zombie:
			creature_to_spawn = preload("res://Characters/zombie.tscn")
		GraveType.Skeleton:
			print("not implemented yet")
			#creature_to_spawn = preload("res://Characters/skeleton.tscn")


func spawn_character():
	#print("spawning thing from grave!")
	if creature_to_spawn == null:
		creature_to_spawn = preload("res://Characters/zombie.tscn")

	if not creature_to_spawn == null:
		var creature = creature_to_spawn.instantiate()
		creature.process_mode = PROCESS_MODE_DISABLED
		creature.position = Vector3(global_position.x, start_height, global_position.z)
		$CreatureHolder.add_child(creature)
		target_height = start_height
		velocity = -RAISE_VELOCITY
