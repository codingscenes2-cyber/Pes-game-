extends RigidBody3D
class_name FootballBall

func _ready() -> void:
	mass = 0.43
	linear_damp = 0.48
	angular_damp = 0.32
	continuous_cd = true
	can_sleep = false
	var sphere := SphereShape3D.new()
	sphere.radius = 0.22
	var collision := CollisionShape3D.new()
	collision.shape = sphere
	add_child(collision)
	var mesh_instance := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.22
	mesh.height = 0.44
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.93, 0.93, 0.88)
	material.roughness = 0.48
	mesh.material = material
	mesh_instance.mesh = mesh
	add_child(mesh_instance)
	var physics_material := PhysicsMaterial.new()
	physics_material.friction = 0.48
	physics_material.bounce = 0.38
	physics_material_override = physics_material

func kick(direction: Vector3, power: float, lift: float = 0.0, spin: float = 0.0) -> void:
	var shot_direction := direction.normalized()
	apply_central_impulse(shot_direction * power + Vector3.UP * lift)
	if absf(spin) > 0.001:
		apply_torque_impulse(Vector3.UP * spin)

func reset_ball(at: Vector3) -> void:
	global_position = at
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	sleeping = false
