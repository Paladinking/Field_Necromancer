extends AnimatableBody3D


const RAISE_VELOCITY = 1
const CREATURE_START_DEPTH = 5
var moving : bool = false
var target_height : float
var creature_to_spawn

func _ready():
	pass # Replace with function body.


func _process(delta):
	if moving:
		var velocity : Vector3 = Vector3.ZERO
		velocity.y = (target_height - position.y) * 2

		if velocity.y < 0:
			velocity.y = min(velocity.y, -RAISE_VELOCITY)
		else:
			velocity.y = max(velocity.y, RAISE_VELOCITY)
		#print("velocity: ", velocity.y, " position: ", position.y)

		move_and_collide(velocity * delta)
		if $CreatureHolder.get_child_count() > 0:
			$CreatureHolder.get_child(0).position.y = (target_height - position.y) * CREATURE_START_DEPTH

		if abs(position.y - target_height) < 0.01:
			moving = false
			position.y = target_height
			#print("done moving grave")

			if $CreatureHolder.get_child_count() > 0:
				var child = $CreatureHolder.get_child(0)
				child.process_mode = PROCESS_MODE_INHERIT
				child.reparent(get_parent())


func raise(ground_height : float = 0.0):
	moving = true
	target_height = ground_height


func set_type(type : String = "zombie"):
	match type:
		"zombie":
			creature_to_spawn = preload("res://Characters/zombie.tscn")
		"skeleton":
			print("not implemented yet")


func spawn_character():
	print("spawning thing from grave!")
	if not creature_to_spawn == null:
		var creature = creature_to_spawn.instantiate()
		creature.process_mode = PROCESS_MODE_DISABLED
		creature.position = position - Vector3(0, CREATURE_START_DEPTH, 0)
		$CreatureHolder.add_child(creature)
		target_height = position.y - 1
		moving = true
