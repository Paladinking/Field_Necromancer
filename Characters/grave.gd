class_name Grave
extends AnimatableBody3D


const RAISE_VELOCITY = 5

var velocity : float
var target_height : float
var start_height : float

var creature_to_spawn

var type : GraveType = GraveType.Zombie

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
				var child = $CreatureHolder.get_child(0) as Zombie
				child.process_mode = PROCESS_MODE_INHERIT
				var parent = get_tree().get_nodes_in_group("Allies")[0]
				child.reparent(parent)
				child.raising = false
				child.set_collision_layer_value(1, true)

				queue_free()


func raise(ground_height : float = 0.0):
	velocity = RAISE_VELOCITY
	target_height = ground_height

enum GraveType {Zombie, Skeleton}

func set_type(_type : GraveType = GraveType.Zombie):
	creature_to_spawn = preload("res://Characters/zombie.tscn")
	self.type = _type


func spawn_character():
	if creature_to_spawn == null:
		creature_to_spawn = preload("res://Characters/zombie.tscn")

	if not creature_to_spawn == null:
		var creature : Zombie = creature_to_spawn.instantiate() as Zombie
		#creature.process_mode = PROCESS_MODE_DISABLED
		creature.raising = true
		creature.set_collision_layer_value(1, false)
		creature.position = Vector3(global_position.x, start_height, global_position.z)
		$CreatureHolder.add_child(creature)
		creature.find_child("*AnimationPlayer").play("March")
		target_height = start_height
		velocity = -RAISE_VELOCITY
		if type == GraveType.Skeleton:
			creature.is_skeleton = true
			creature._hp = creature._hp / 2
			creature._max_hp = creature._hp
			creature.dmg = creature.dmg / 2
			var mat = creature.get_node("CSGCylinder3D").get_material().duplicate()
			mat.albedo_color = Color(0.8,0.8,0.8)
			creature.get_node("CSGCylinder3D").set_material(mat)
