class_name Entity
extends CharacterBody3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _collision_acceleration : Vector3 = Vector3(0, 0, 0)

@export var _hp : int

signal on_death

func damage(dmg: int, dir: Vector3):
	if _hp <= 0:
		return
	_hp -= dmg
	
	if self is Fighter:
		$FullHealth.visible = true
		$EmptyHealth.visible = true
		var ratio = float(_hp) / float(self._max_hp)
		var full = int(20 * ratio)
		var empty = 20 - full
		if (full > 0):
			$FullHealth.set_text("█".repeat(full))
		else:
			$FullHealth.set_text("")
		if (empty > 0):
			$EmptyHealth.set_text("█".repeat(empty))
		else:
			$EmptyHealth.set_text("")
	if _hp <= 0:
		on_death.emit(dir)

func _finalize_move(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta
	velocity += _collision_acceleration
	_collision_acceleration *= 0.9
	var collision_info = move_and_collide(velocity * delta, true)
	if collision_info:
		for i in collision_info.get_collision_count():
			var collider = collision_info.get_collider(i)
			var dir = (collision_info.get_position(i) - position).normalized()
			dir.y = 0
			if collider is Entity:
				collider._collision_acceleration = 5 * dir
	move_and_slide()
