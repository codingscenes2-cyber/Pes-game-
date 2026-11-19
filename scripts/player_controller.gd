extends CharacterBody3D
class_name FootballPlayer

@export var move_speed: float = 6.4
@export var sprint_speed: float = 8.6
@export var acceleration: float = 22.0
@export var braking: float = 27.0
@export var turn_speed: float = 10.0

var move_input: Vector2 = Vector2.ZERO
var is_sprinting: bool = false
var team_id: int = 0
var shirt_color: Color = Color(0.12, 0.38, 0.92)
var body_mesh: MeshInstance3D
var visual_root: Node3D

func configure(team: int, color: Color, controlled: bool = false) -> void:
	team_id = team
	shirt_color = color
	set_meta("user_controlled", controlled)

func _ready() -> void:
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	floor_snap_length = 0.25
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.34
	capsule.height = 1.65
	var collision := CollisionShape3D.new()
	collision.shape = capsule
	collision.position.y = 0.83
	add_child(collision)

	visual_root = Node3D.new()
	visual_root.name = "VisualRoot"
	add_child(visual_root)
	body_mesh = MeshInstance3D.new()
	var body := CapsuleMesh.new()
	body.radius = 0.34
	body.height = 1.65
	body.material = _make_material(shirt_color)
	body_mesh.mesh = body
	body_mesh.position.y = 0.83
	visual_root.add_child(body_mesh)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.19
	head_mesh.height = 0.38
	head_mesh.material = _make_material(Color(0.78, 0.61, 0.46))
	head.mesh = head_mesh
	head.position = Vector3(0, 1.72, 0)
	visual_root.add_child(head)

func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	return material

func _physics_process(delta: float) -> void:
	var direction := Vector3(move_input.x, 0.0, move_input.y)
	if direction.length_squared() > 1.0:
		direction = direction.normalized()
	var target_speed := sprint_speed if is_sprinting else move_speed
	var target_velocity := direction * target_speed
	var rate := acceleration if direction.length_squared() > 0.001 else braking
	velocity.x = move_toward(velocity.x, target_velocity.x, rate * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, rate * delta)
	if not is_on_floor():
		velocity.y -= 22.0 * delta
	else:
		velocity.y = -0.5
	if direction.length_squared() > 0.01:
		var target_yaw := atan2(-direction.x, -direction.z)
		visual_root.rotation.y = rotate_toward(visual_root.rotation.y, target_yaw, turn_speed * delta)
	move_and_slide()
