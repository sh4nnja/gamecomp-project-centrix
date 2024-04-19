# ******************************************************************************
# hekara.gd
# ******************************************************************************
#                             This file is part of
#                                   Centrix
# ******************************************************************************
# Copyright (c) 2024-present University of Cabuyao
# 
# Developers
# Shannja Ashley Malelang
# Miccael Jasper Tayas
# Jhovic Cortel
#
# Adviser
# Paulo Edrozo
# ******************************************************************************

extends CharacterBody2D

# DAMAGE ***********************************************************************
var _damage_fx: Resource = load("res://assets/global/sounds/fx/385046__mortisblack__damage.ogg")
var _laugh_fx: Resource = load("res://assets/global/sounds/fx/179924__craiggroshek__laughing-witch-or-old-woman-in-a-rocking-chair.wav")
var _spawn_fx: Resource = load("res://assets/global/sounds/fx/315930__bevibeldesign__sucked-into-classroom.wav")

# FLOOZE ***********************************************************************
var _flooze: Resource = load("res://assets/objects/enemies/flooze/flooze.tscn")

# SKILLS ***********************************************************************
var _detected_enemy: CharacterBody2D = null
var _spawn_dur: int = 6

var health: float = 100.0
var hit: float = 20.0

# NODES ************************************************************************
@onready var _anim_blend: AnimationTree = get_node("anim_blend")
@onready var _anim_alert: AnimatedSprite2D = get_node("alert")

@onready var _sound: AudioStreamPlayer2D = get_node("sound")
@onready var _shape: CollisionShape2D = get_node("detection/shape")

@onready var _spawn_anim: AnimationPlayer = get_node("spawn_anim")
@onready var _spawn_timer: Timer = get_node("spawn_duration")

# VIRTUAL **********************************************************************
func _ready() -> void:
	# Enable animation.
	_anim_blend.set_active(true)
	_rand_aggro() 

func _physics_process(_delta: float) -> void:
	_manage_animation()

# CUSTOM ***********************************************************************
# Animation handler.
func _manage_animation() -> void:
	if _detected_enemy:
		if health > 0:
			_anim_blend.get("parameters/playback").travel("idle")
			_anim_blend.set("parameters/idle/blend_position", Vector2(-1, 0) if position > _detected_enemy.position else Vector2(1, 0))
		else:
			_anim_blend.get("parameters/playback").travel("dead")
			_anim_blend.set("parameters/dead/blend_position", Vector2(-1, 0) if position > _detected_enemy.position else Vector2(1, 0))

func _rand_aggro() -> void:
	var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
	_rng.randomize()
	_rng.set_seed(_rng.randi())
	_shape.get_shape().set_radius(_rng.randi_range(10, 25) * 10)

func _enable_spawn_flooze(_enable: bool) -> void:
	if _enable and health > 0:
		var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
		_rng.randomize()
		_rng.set_seed(_rng.randi())
		_spawn_timer.start(_rng.randi_range(3, _spawn_dur))
	else:
		_spawn_timer.stop()

func _spawn_flooze():
	_spawn_anim.play("spawn")

func spawn() -> void:
	if not get_tree().is_paused():
		
		_sound.set_stream(_spawn_fx)
		_sound.play()
		
		var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
		_rng.randomize()
		_rng.set_seed(_rng.randi())
		
		# Creates flooze.
		var _flooze_inst: Object = _flooze.instantiate()
		
		# Add to the tree.
		get_parent().add_child(_flooze_inst)
		_flooze_inst.global_position = global_position 

func damage(_multiplier: int = 1) -> void:
	if not _sound.is_playing():
		_sound.set_stream(_damage_fx)
		_sound.play()
	else:
		if _sound.get_stream() != _damage_fx:
			_sound.set_stream(_damage_fx)
			_sound.play()
	
	modulate = Color.html("ff0000")
	await get_tree().create_timer(0.1).timeout
	modulate = Color.html("ffffff")
	health -= hit * _multiplier

func die() -> void:
	_anim_alert.play_backwards("alert")
	await _anim_alert.animation_finished
	_anim_alert.hide()
	_spawn_timer.stop()
	process_mode = Node.PROCESS_MODE_DISABLED

# SIGNALS **********************************************************************
func _on_detection_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Slix"):
		_detected_enemy = _body
		set_collision_mask_value(1, true)
		_anim_alert.play("alert")
		_sound.set_stream(_laugh_fx)
		_sound.play()
		_enable_spawn_flooze(true)

func _on_detection_body_exited(_body: Node2D) -> void:
	if _body.is_in_group("Slix"):
		_detected_enemy = null
		set_collision_mask_value(1, false)
		_anim_alert.play_backwards("alert")
		_enable_spawn_flooze(false)
		_rand_aggro()

func _on_spawn_duration_timeout() -> void:
	_spawn_flooze()
