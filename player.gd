extends RigidBody3D


## How much vertical force to apply when moving
@export_range(750, 3000) var thrust: float = 1000.0

@export var torque_trust: float = 100

var is_transitioning: bool = false

@onready var explosion_audio: AudioStreamPlayer3D = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer3D = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var exhaust_center: GPUParticles3D = $ExhaustCenter
@onready var exhaust_right: GPUParticles3D = $ExhaustRight
@onready var exhaust_left: GPUParticles3D = $ExhaustLeft
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		exhaust_center.emitting = true
		if not rocket_audio.playing:
			rocket_audio.play()
	else:
		exhaust_center.emitting = false
		rocket_audio.stop()

	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0, 0, torque_trust * delta))
		exhaust_right.emitting = true
	else:
		exhaust_right.emitting = false
	
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0, 0, -torque_trust * delta))
		exhaust_left.emitting = true
	else:
		exhaust_left.emitting = false


func _on_body_entered(body: Node) -> void:
	if is_transitioning == false:
		if body.is_in_group("Goal"):
			is_transitioning = true
			complete_level(body.file_path)
		if body.is_in_group("Hazard"):
			is_transitioning = true
			crash_sequence()

func crash_sequence() -> void:
	print("KABOOM")
	explosion_particles.emitting = true
	set_process(false)
	explosion_audio.play()
	var tween = create_tween()
	tween.tween_interval(1)
	tween.tween_callback(get_tree().reload_current_scene)

func complete_level(next_level_file: String) -> void:
	print("You Won")
	success_particles.emitting = true
	set_process(false)
	success_audio.play()
	var tween = create_tween()
	tween.tween_interval(1)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))
	
