class_name Entity
extends CharacterBody3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _collision_acceleration : Vector3 = Vector3(0, 0, 0)

func _finalize_move(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta
	velocity += _collision_acceleration
	_collision_acceleration *= 0.9
	var collision_info = move_and_collide(Vector3(velocity.x, 0, velocity.z) * delta, true)
	if collision_info:
		for i in collision_info.get_collision_count():
			var collider = collision_info.get_collider(i)
			var dir = (collision_info.get_position(i) - position).normalized()
			dir.y = 0
			if collider is CharacterBody3D:
				collider._collision_acceleration = 5 * dir
	move_and_slide()
