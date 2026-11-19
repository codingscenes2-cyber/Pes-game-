extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player_controller.gd")
const BALL_SCRIPT = preload("res://scripts/football_ball.gd")
const PITCH_LENGTH := 30.0
const PITCH_WIDTH := 20.0

var controlled_player: FootballPlayer
var ball: FootballBall
var players: Array[FootballPlayer] = []
var camera: Camera3D
var score_home := 0
var score_away := 0
var match_time := 0.0
var touch_state := {"up": false, "down": false, "left": false, "right": false, "sprint": false, "shield": false}
var score_label: Label
var status_label: Label
var action_cooldown := 0.0
var dribble_cooldown := 0.0
var tackle_cooldown := 0.0
var possession_player: FootballPlayer
var possession_lock_timer := 0.0
var shielding := false

const HOME_COLOR := Color(0.08, 0.32, 0.94)
const AWAY_COLOR := Color(0.88, 0.16, 0.12)

func _ready() -> void:
	_build_world()
	_spawn_teams()
	_spawn_ball()
	_build_camera()
	_build_hud()
	_update_score()

func _build_world() -> void:
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.035, 0.075, 0.065)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.72, 0.78, 0.82)
	env.ambient_light_energy = 0.75
	environment.environment = env
	add_child(environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, -28, 0)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)

	_add_box("Pitch", Vector3(PITCH_WIDTH, 0.25, PITCH_LENGTH), Vector3(0, -0.18, 0), Color(0.10, 0.39, 0.19), true)
	for i in range(10):
		var stripe_color := Color(0.12, 0.43, 0.21) if i % 2 == 0 else Color(0.095, 0.37, 0.17)
		_add_box("MowingStripe", Vector3(PITCH_WIDTH, 0.012, 3.0), Vector3(0, -0.045, -13.5 + i * 3.0), stripe_color)
	_add_box("HalfwayLine", Vector3(PITCH_WIDTH, 0.018, 0.07), Vector3(0, -0.025, 0), Color.WHITE)
	_add_box("CenterMark", Vector3(0.18, 0.025, 0.18), Vector3(0, -0.015, 0), Color.WHITE)
	_add_box("TouchlineNorth", Vector3(PITCH_WIDTH, 0.025, 0.07), Vector3(0, -0.02, -15), Color.WHITE)
	_add_box("TouchlineSouth", Vector3(PITCH_WIDTH, 0.025, 0.07), Vector3(0, -0.02, 15), Color.WHITE)
	_add_box("TouchlineWest", Vector3(0.07, 0.025, PITCH_LENGTH), Vector3(-10, -0.02, 0), Color.WHITE)
	_add_box("TouchlineEast", Vector3(0.07, 0.025, PITCH_LENGTH), Vector3(10, -0.02, 0), Color.WHITE)
	_add_box("CenterCircleTop", Vector3(4.2, 0.02, 0.07), Vector3(0, -0.015, -2.1), Color.WHITE)
	_add_box("CenterCircleBottom", Vector3(4.2, 0.02, 0.07), Vector3(0, -0.015, 2.1), Color.WHITE)
	_add_box("LeftPenaltyLine", Vector3(0.07, 0.02, 6.0), Vector3(-3.5, -0.015, -12), Color.WHITE)
	_add_box("RightPenaltyLine", Vector3(0.07, 0.02, 6.0), Vector3(3.5, -0.015, -12), Color.WHITE)
	_add_box("PenaltyTop", Vector3(7.0, 0.02, 0.07), Vector3(0, -0.015, -9), Color.WHITE)
	_add_box("PenaltyBottom", Vector3(7.0, 0.02, 0.07), Vector3(0, -0.015, 9), Color.WHITE)
	_add_goal(-15.0)
	_add_goal(15.0)

func _add_box(label: String, size: Vector3, at: Vector3, color: Color, solid: bool = false) -> void:
	var root: Node3D
	if solid:
		var body := StaticBody3D.new()
		root = body
		var shape := BoxShape3D.new()
		shape.size = size
		var collision := CollisionShape3D.new()
		collision.shape = shape
		body.add_child(collision)
	else:
		root = Node3D.new()
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	mesh.material = material
	mesh_instance.mesh = mesh
	root.add_child(mesh_instance)
	root.position = at
	root.name = label
	add_child(root)

func _add_goal(z: float) -> void:
	var goal_color := Color(0.92, 0.94, 0.96)
	_add_box("GoalPost", Vector3(0.18, 2.3, 0.18), Vector3(-3.0, 1.15, z), goal_color, true)
	_add_box("GoalPost", Vector3(0.18, 2.3, 0.18), Vector3(3.0, 1.15, z), goal_color, true)
	_add_box("GoalCrossbar", Vector3(6.0, 0.18, 0.18), Vector3(0, 2.3, z), goal_color, true)
	_add_box("GoalBack", Vector3(6.0, 2.2, 0.12), Vector3(0, 1.1, z + (0.9 if z < 0 else -0.9)), Color(0.8, 0.84, 0.86, 0.35))

func _spawn_teams() -> void:
	for i in range(11):
		var home := PLAYER_SCRIPT.new() as FootballPlayer
		home.configure(0, HOME_COLOR, i == 9)
		home.position = _formation_position(i, 0)
		add_child(home)
		players.append(home)
		if i == 9:
			controlled_player = home
		var away := PLAYER_SCRIPT.new() as FootballPlayer
		away.configure(1, AWAY_COLOR, false)
		away.position = _formation_position(i, 1)
		add_child(away)
		players.append(away)

func _formation_position(index: int, team: int) -> Vector3:
	var sign := -1.0 if team == 0 else 1.0
	var positions := [
		Vector3(0, 0, 12),
		Vector3(-7, 0, 8), Vector3(-2.3, 0, 8), Vector3(2.3, 0, 8), Vector3(7, 0, 8),
		Vector3(-6, 0, 2), Vector3(0, 0, 3), Vector3(6, 0, 2),
		Vector3(-5, 0, -4), Vector3(0, 0, -5), Vector3(5, 0, -4)
	]
	var p: Vector3 = positions[index]
	return Vector3(p.x, 0, p.z * sign)

func _spawn_ball() -> void:
	ball = BALL_SCRIPT.new() as FootballBall
	ball.position = Vector3(0, 0.24, 0)
	add_child(ball)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 54
	add_child(camera)
	camera.position = Vector3(0, 13, 18)
	camera.look_at(Vector3.ZERO, Vector3.UP)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(18, 16)
	panel.custom_minimum_size = Vector2(250, 66)
	layer.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	score_label = Label.new()
	score_label.add_theme_font_size_override("font_size", 25)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(score_label)
	status_label = Label.new()
	status_label.text = "EXHIBITION  •  90:00"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(status_label)

	var controls := HBoxContainer.new()
	controls.anchor_left = 0.0
	controls.anchor_top = 1.0
	controls.anchor_right = 1.0
	controls.anchor_bottom = 1.0
	controls.offset_left = 18
	controls.offset_top = -360
	controls.offset_right = -18
	controls.offset_bottom = -18
	controls.alignment = BoxContainer.ALIGNMENT_END
	layer.add_child(controls)

	var pad := GridContainer.new()
	pad.columns = 3
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.add_child(pad)
	_add_spacer(pad)
	_add_touch_button(pad, "▲", "up", 62)
	_add_spacer(pad)
	_add_touch_button(pad, "◀", "left", 62)
	_add_touch_button(pad, "▼", "down", 62)
	_add_touch_button(pad, "▶", "right", 62)

	var action_column := VBoxContainer.new()
	action_column.add_theme_constant_override("separation", 0)
	controls.add_child(action_column)
	_add_action_button(action_column, "SHOOT", _shoot, 92)
	_add_action_button(action_column, "FINESSE", _shoot_finesse, 92)
	_add_action_button(action_column, "CHIP", _shoot_chip, 92)
	_add_action_button(action_column, "PASS", _pass, 92)
	_add_action_button(action_column, "THROUGH", _through_pass, 92)
	_add_action_button(action_column, "SWITCH", _switch_player, 92)
	_add_action_button(action_column, "TACKLE", _tackle, 92)
	_add_touch_button(action_column, "SHIELD", "shield", 92)
	_add_touch_button(action_column, "SPRINT", "sprint", 92)

func _add_spacer(parent: Control) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(62, 62)
	parent.add_child(spacer)

func _add_touch_button(parent: Node, caption: String, key: String, width: float) -> void:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(width, 58)
	button.button_down.connect(func(): touch_state[key] = true)
	button.button_up.connect(func(): touch_state[key] = false)
	parent.add_child(button)

func _add_action_button(parent: Node, caption: String, action: Callable, width: float) -> void:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(width, 40)
	button.pressed.connect(action)
	parent.add_child(button)

func _physics_process(delta: float) -> void:
	match_time += delta
	action_cooldown = maxf(0.0, action_cooldown - delta)
	dribble_cooldown = maxf(0.0, dribble_cooldown - delta)
	tackle_cooldown = maxf(0.0, tackle_cooldown - delta)
	_update_user_input()
	_update_possession(delta)
	_update_dribble_control()
	_update_ai(delta)
	_check_goal()
	if int(match_time) % 30 == 0 and int(match_time * 10.0) % 10 == 0:
		status_label.text = "EXHIBITION  •  %02d:%02d" % [int(match_time) / 60, int(match_time) % 60]

func _process(delta: float) -> void:
	if is_instance_valid(controlled_player) and is_instance_valid(camera):
		var target := controlled_player.global_position + Vector3(0, 10.5, 13.0)
		camera.global_position = camera.global_position.lerp(target, 1.0 - exp(-3.5 * delta))
		camera.look_at(controlled_player.global_position + Vector3(0, 0.5, -1.5), Vector3.UP)

func _update_user_input() -> void:
	var x := 0.0
	var y := 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT) or touch_state.left: x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT) or touch_state.right: x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP) or touch_state.up: y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN) or touch_state.down: y += 1.0
	controlled_player.move_input = Vector2(x, y).normalized()
	controlled_player.is_sprinting = Input.is_key_pressed(KEY_SHIFT) or touch_state.sprint
	shielding = Input.is_key_pressed(KEY_E) or touch_state.shield
	if Input.is_key_just_pressed(KEY_J): _pass()
	if Input.is_key_just_pressed(KEY_K): _shoot()
	if Input.is_key_just_pressed(KEY_U): _through_pass()
	if Input.is_key_just_pressed(KEY_Q): _switch_player()
	if Input.is_key_just_pressed(KEY_P): _tackle()
	if Input.is_key_just_pressed(KEY_I): _shoot_finesse()
	if Input.is_key_just_pressed(KEY_O): _shoot_chip()

func _update_ai(delta: float) -> void:
	for p in players:
		if p == controlled_player:
			continue
		var to_ball := ball.global_position - p.global_position
		var is_nearest := true
		for other in players:
			if other.team_id != p.team_id and other.global_position.distance_squared_to(ball.global_position) < p.global_position.distance_squared_to(ball.global_position):
				is_nearest = false
				break
		var target := Vector3.ZERO
		if is_nearest and p.team_id != 0:
			target = ball.global_position
		elif p.team_id == 0 and p.global_position.distance_to(ball.global_position) < 8.0:
			target = ball.global_position
		else:
			var home := _formation_position(int(players.find(p) / 2), p.team_id)
			target = home
		var direction := target - p.global_position
		direction.y = 0
		p.move_input = Vector2(direction.x, direction.z).normalized() if direction.length() > 1.0 else Vector2.ZERO
		p.is_sprinting = is_nearest and direction.length() > 4.0
		if p.team_id == 1 and p.global_position.distance_to(ball.global_position) < 1.15 and action_cooldown <= 0.0:
			_ball_kick(p, Vector3(0, 0, 1), 8.0, 1.1)
			action_cooldown = 0.9

func _nearest_home_player() -> FootballPlayer:
	var nearest: FootballPlayer = controlled_player
	var best := INF
	for p in players:
		if p.team_id == 0:
			var d := p.global_position.distance_squared_to(ball.global_position)
			if d < best:
				best = d
				nearest = p
	return nearest

func _pass() -> void:
	if action_cooldown > 0.0: return
	var receiver: FootballPlayer
	var best := INF
	for p in players:
		if p.team_id == 0 and p != controlled_player:
			var d := p.global_position.distance_squared_to(controlled_player.global_position)
			if d < best and controlled_player.global_position.direction_to(p.global_position).dot(-controlled_player.visual_root.global_transform.basis.z) > -0.1:
				best = d
				receiver = p
	if receiver:
		_ball_kick(controlled_player, controlled_player.global_position.direction_to(receiver.global_position), 7.0, 0.35)
	else:
		_ball_kick(controlled_player, -controlled_player.visual_root.global_transform.basis.z, 6.0, 0.25)
	action_cooldown = 0.35

func _shoot() -> void:
	if action_cooldown > 0.0: return
	var goal_direction := Vector3(0, 0, -1)
	_ball_kick(controlled_player, goal_direction, 13.5, 1.0)
	action_cooldown = 0.45

func _through_pass() -> void:
	if action_cooldown > 0.0: return
	var forward := -controlled_player.visual_root.global_transform.basis.z
	var receiver: FootballPlayer
	var best_score := -INF
	for p in players:
		if p.team_id != 0 or p == controlled_player:
			continue
		var offset := p.global_position - controlled_player.global_position
		var distance := offset.length()
		if distance < 2.0 or distance > 18.0:
			continue
		var forwardness := forward.dot(offset.normalized())
		if forwardness < 0.35:
			continue
		var score := forwardness * 5.0 - distance * 0.08
		if score > best_score:
			best_score = score
			receiver = p
	if receiver:
		var lead := receiver.global_position + receiver.velocity * 0.32
		var direction := (lead - controlled_player.global_position).normalized()
		_ball_kick(controlled_player, direction, 9.0, 0.42)
	else:
		_ball_kick(controlled_player, forward, 8.5, 0.38)
	action_cooldown = 0.5

func _switch_player() -> void:
	var next_player := _nearest_home_player()
	if is_instance_valid(next_player):
		controlled_player = next_player

func _tackle() -> void:
	if tackle_cooldown > 0.0:
		return
	var opponent: FootballPlayer
	var nearest_distance := 1.45
	for p in players:
		if p.team_id == controlled_player.team_id:
			continue
		var distance := controlled_player.global_position.distance_to(p.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			opponent = p
	if opponent:
		var knockback := (opponent.global_position - controlled_player.global_position).normalized()
		knockback.y = 0.0
		opponent.velocity.x += knockback.x * 2.8
		opponent.velocity.z += knockback.z * 2.8
		if opponent.global_position.distance_to(ball.global_position) < 1.65 or controlled_player.global_position.distance_to(ball.global_position) < 1.9:
			possession_player = null
			possession_lock_timer = 0.18
			var ball_direction := (ball.global_position - controlled_player.global_position).normalized()
			ball.apply_central_impulse(ball_direction * 3.2 + Vector3.UP * 0.25)
	tackle_cooldown = 1.1

func _shoot_finesse() -> void:
	if action_cooldown > 0.0: return
	var forward := -controlled_player.visual_root.global_transform.basis.z
	var goal_target := Vector3(0, 1.0, -15.0)
	var direction := (goal_target - controlled_player.global_position).normalized()
	var curve_side := -1.0 if controlled_player.global_position.x > 0.0 else 1.0
	_ball_kick(controlled_player, (direction + Vector3(curve_side * 0.12, 0.04, 0)).normalized(), 10.5, 0.72)
	ball.kick(Vector3.UP, 0.0, 0.0, curve_side * 0.7)
	action_cooldown = 0.55

func _shoot_chip() -> void:
	if action_cooldown > 0.0: return
	var direction := Vector3(0, 0, -1)
	_ball_kick(controlled_player, direction, 8.0, 2.8)
	action_cooldown = 0.55

func _update_possession(delta: float) -> void:
	possession_lock_timer = maxf(0.0, possession_lock_timer - delta)
	if is_instance_valid(possession_player):
		var owner_distance := possession_player.global_position.distance_to(ball.global_position)
		if owner_distance > 2.15 or possession_player.is_queued_for_deletion():
			possession_player = null
		else:
			var move_direction := Vector3(possession_player.move_input.x, 0.0, possession_player.move_input.y)
			var facing := -possession_player.visual_root.global_transform.basis.z
			var carry_direction := facing
			if move_direction.length_squared() > 0.04:
				carry_direction = move_direction.normalized()
			var side_offset := Vector3(-carry_direction.z, 0.0, carry_direction.x) * (0.48 if possession_player == controlled_player and shielding else 0.0)
			var carry_distance := 0.82 if possession_player == controlled_player and shielding else 0.72
			var target := possession_player.global_position + carry_direction * carry_distance + side_offset + Vector3.UP * 0.22
			var error := target - ball.global_position
			var force := error * 16.0 - ball.linear_velocity * 4.2
			ball.apply_central_force(force.limit_length(32.0) * ball.mass)
			return
	if possession_lock_timer > 0.0 or ball.linear_velocity.length() > 5.0:
		return
	var candidate: FootballPlayer
	var best_distance := 1.12
	for p in players:
		var distance := p.global_position.distance_to(ball.global_position)
		if distance < best_distance:
			best_distance = distance
			candidate = p
	if candidate:
		var relative_speed := ball.linear_velocity.length()
		if relative_speed < 4.2:
			possession_player = candidate
			ball.linear_velocity *= 0.28
			ball.angular_velocity *= 0.45

func _update_dribble_control() -> void:
	if possession_player != controlled_player:
		return
	if dribble_cooldown > 0.0 or controlled_player.move_input.length_squared() < 0.05:
		return
	var facing := -controlled_player.visual_root.global_transform.basis.z
	var foot_target := controlled_player.global_position + facing * 0.78 + Vector3.UP * 0.18
	if ball.global_position.distance_to(foot_target) > 1.35 or ball.linear_velocity.length() > 8.0:
		return
	var move_direction := Vector3(controlled_player.move_input.x, 0.0, controlled_player.move_input.y).normalized()
	var touch_direction := (move_direction + facing * 0.25).normalized()
	ball.apply_central_impulse(touch_direction * (0.30 if controlled_player.is_sprinting else 0.22))
	dribble_cooldown = 0.30

func _ball_kick(kicker: FootballPlayer, direction: Vector3, power: float, lift: float) -> void:
	if kicker.global_position.distance_to(ball.global_position) > 2.0:
		return
	possession_player = null
	possession_lock_timer = 0.32
	ball.global_position = kicker.global_position + direction.normalized() * 0.82 + Vector3.UP * 0.18
	ball.linear_velocity = Vector3.ZERO
	ball.kick(direction, power, lift)

func _check_goal() -> void:
	if ball.global_position.z < -15.2 and absf(ball.global_position.x) < 3.0:
		score_home += 1
		_reset_after_goal()
	elif ball.global_position.z > 15.2 and absf(ball.global_position.x) < 3.0:
		score_away += 1
		_reset_after_goal()

func _reset_after_goal() -> void:
	_update_score()
	ball.reset_ball(Vector3(0, 0.24, 0))
	for p in players:
		p.position = _formation_position(int(players.find(p) / 2), p.team_id)

func _update_score() -> void:
	if is_instance_valid(score_label):
		score_label.text = "BLUE  %d  -  %d  RED" % [score_home, score_away]
