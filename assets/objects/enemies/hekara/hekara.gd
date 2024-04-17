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

# SKILLS ***********************************************************************
var _detected_enemy: CharacterBody2D = null

var health: float = 100.0
var hit: float = 20.0

# NODES ************************************************************************
@onready var _anim_blend: AnimationTree = get_node("anim_blend")
@onready var _anim_alert: AnimatedSprite2D = get_node("alert")

@onready var _sound: AudioStreamPlayer2D = get_node("sound")
@onready var _shape: CollisionShape2D = get_node("detection/shape")

# VIRTUAL **********************************************************************
func _ready() -> void:
	# Enable animation.
	_anim_blend.set_active(true)

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
			_anim_blend.set("parameters/idle/blend_position", Vector2(-1, 0) if position > _detected_enemy.position else Vector2(1, 0))

func _rand_aggro() -> void:
	var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
	_rng.randomize()
	_rng.set_seed(_rng.randi())
	_shape.get_shape().set_radius(_rng.randi_range(3, 10) * 10)

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
	process_mode = Node.PROCESS_MODE_DISABLED

# SIGNALS **********************************************************************
func _on_detection_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Slix"):
		_detected_enemy = _body
		set_collision_mask_value(1, true)
		_anim_alert.play("alert")

func _on_detection_body_exited(_body: Node2D) -> void:
	if _body.is_in_group("Slix"):
		_detected_enemy = null
		set_collision_mask_value(1, false)
		_anim_alert.play_backwards("alert")
		_rand_aggro()

