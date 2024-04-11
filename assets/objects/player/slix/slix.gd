# ******************************************************************************
# slix.gd
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

# PROJECTILE *******************************************************************
var _projectile: Resource = load("res://assets/objects/player/projectile/projectile.tscn")

# NODES ************************************************************************
@onready var _texture: AnimatedSprite2D = get_node("texture")
@onready var _anim_blend: AnimationTree = get_node("anim_blend")

@onready var _rfx_blur: CPUParticles2D = get_node("roll_fx/blur")
@onready var _rfx_trail: CPUParticles2D = get_node("roll_fx/trail")
@onready var _gfx_goo: CPUParticles2D = get_node("goowave/goo_fx")

@onready var _sound: AudioStreamPlayer2D = get_node("sound")

# PHYSICS **********************************************************************
const SPEED: float = 50.0

const ROLL_SPEED_MULT: float = 2 # Rolling Speed Mult.

var _vel: Vector2 = Vector2.ZERO # Current velocity.

# SKILLS ANIMATION *************************************************************
var _enabled_roll: bool = false # Facilitates rolling.
var _enabled_devour: bool = false
var _enabled_lash: bool = false
var _enabled_goo: bool = false

var devoured_enemies: int = 0
var devoured_resources: int = 0
var devoured_items: int = 0

# HEALTH ***********************************************************************
# Deduction happens per physics frame.
const TOXIC_ATMOSPHERE: float = 0.005
const TOXIC_LAKE: float = 1
const TOXIC_DEDUCTION_REDUCER: float = 0.01
const IMMUNITY_DURATION: float = 0.25

# Deduction happens on a specific physics frame of the animation.
var rollout_energy: float = 1.25
var lash_energy: float = 2.00
var goowave_energy: float = 20.00

var health: float = 100.0

var reduced_toxicity: float = 0 # Grace period amount before going back to normal deduction.

# GOOWAVE **********************************************************************
var _enemies: Array = []

# RESOURCE *********************************************************************
var _devoured: CharacterBody2D
var _devoured_enemy: Array[CharacterBody2D]
var _devoured_item: CharacterBody2D

# ITEMS ************************************************************************
var item_collected: int = 0

# VIRTUAL **********************************************************************
func _ready() -> void:
	_anim_blend.set_active(true) # Enable animation.

func _physics_process(_delta: float) -> void:
	_manage_health()
	_manage_movement(_delta)
	_manage_movement_anim()
	_manage_skills_anim()
	_manage_effects()

# CUSTOM ***********************************************************************
# Movement handler.
func _manage_movement(_delta: float) -> void:
	_vel = Vector2.ZERO
	
	# Take note of the movement.
	# Movement left to right.
	_vel.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	_vel.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	# Rolling.
	if Input.is_action_pressed("roll"):
		_enabled_roll = true
	elif Input.is_action_just_released("roll"):
		_enabled_roll = false
	
	# Apply the velocity and move.
	if _enabled_roll:
		velocity = _vel.normalized() * SPEED * ROLL_SPEED_MULT
	else:
		velocity = _vel.normalized() * SPEED
	
	move_and_slide()

# Skills Animation handler.
func _manage_skills_anim() -> void:
	# Lash.
	if Input.is_action_just_pressed("lash"):
		_enabled_lash = true
	
	# Devour.
	elif Input.is_action_just_pressed("devour"):
		_enabled_devour = true
	
	# Goowave.
	elif Input.is_action_just_pressed("goowave"):
		_enabled_goo = true
	
	# Atmosphere Deduction.
	_toxic_atmosphere_deduction()

# Animation handler.
func _manage_movement_anim() -> void:
	# Movement and Idle.
	if _vel == Vector2.ZERO:
		_anim_blend.get("parameters/playback").travel("idle")
	else:
		# Set the frame to freeze.
		_anim_blend.set("parameters/idle/blend_position", _vel)
		
		# Animation for running.
		_anim_blend.get("parameters/playback").travel("running")
		_anim_blend.set("parameters/running/blend_position", _vel)
	
	# Transform to roll.
	if _enabled_roll:
		_anim_blend.get("parameters/playback").travel("rolling")
	
	# Death.
	if health == 0:
		_anim_blend.get("parameters/playback").travel("death")
	
	# ******************************************************************************
	# Make sure that the animations will not play when rolling.
	if not _enabled_roll:
		# Devour animation.
		if _enabled_devour:
			_enabled_devour = false
			_anim_blend.get("parameters/playback").travel("devour")
			_anim_blend.set("parameters/devour/blend_position", Vector2(get_global_mouse_position() - global_position).normalized())
		
		# Lash animation.
		if _enabled_lash:
			_enabled_lash = false
			_anim_blend.get("parameters/playback").travel("lash")
			_anim_blend.set("parameters/lash/blend_position", Vector2(get_global_mouse_position() - global_position).normalized())
		
		# Goowave animation.
		if _enabled_goo:
			_enabled_goo = false
			_anim_blend.get("parameters/playback").travel("goowave")

# Effect handler.
func _manage_effects() -> void:
	# Set trail whenever rolling is enabled.
	if _enabled_roll:
		# Checks if moving to enable the fx.
		var _is_moving: bool = true if _vel != Vector2.ZERO else false
		_rfx_trail.set_emitting(_is_moving)
		_rfx_blur.set_emitting(_is_moving)
	
	# Disable fx whenever rolling is not enabled.
	else:
		_rfx_trail.set_emitting(_enabled_roll)
		_rfx_blur.set_emitting(_enabled_roll)

# Manage health.
func _manage_health() -> void:
	if health > 100:
		health = 100
	elif health < 0:
		health = 0
	
	if reduced_toxicity > 150:
		reduced_toxicity = 150
	elif reduced_toxicity < 0:
		reduced_toxicity = 0
	
	# Set the colors of all elements
	if health <= 100 and health >= 66:
		modulate = global.slix_colors[0]
	elif health <= 65 and health >= 33:
		modulate = global.slix_colors[1]
	elif health <= 32 and health >= 1:
		modulate = global.slix_colors[2]

# Toxic Lake Deduction.
func toxic_lake_deduction() -> void:
	health -= TOXIC_LAKE

# Toxic Atmosphere Deduction.
func _toxic_atmosphere_deduction() -> void:
	# Reduced.
	if reduced_toxicity > 0:
		reduced_toxicity -= TOXIC_DEDUCTION_REDUCER / IMMUNITY_DURATION
		health -= (TOXIC_ATMOSPHERE * TOXIC_DEDUCTION_REDUCER)
	
	# No Reduction.
	else:
		health -= TOXIC_ATMOSPHERE

# Set the damage sound and look.
func damage(_damage: float) -> void:
	if not _sound.is_playing():
		_sound.set_stream(_damage_fx)
		_sound.play()
	else:
		if _sound.get_stream() != _damage_fx:
			_sound.set_stream(_damage_fx)
			_sound.play()
	
	_texture.modulate = Color.html("ff0000")
	await get_tree().create_timer(0.1).timeout
	_texture.modulate = Color.html("ffffff")
	health -= _damage

# Lowers the energy usage when attacking or doing things
func lower_energy_usage(_mode: bool) -> void:
	if _mode:
		rollout_energy = 0.625
		lash_energy = 1.00
		goowave_energy = 10.00
	else:
		rollout_energy = 1.25
		lash_energy = 2.00
		goowave_energy = 20.00

# The execution of the actions below are located in the animations of Slix.
# The code enable_lash in code are for animation.
func rollout() -> void:
	if _vel != Vector2.ZERO:
		health -= rollout_energy

func devour() -> void:
	# Resource.
	if _devoured:
		# Gets the value of that item.
		var _res_type: int = _devoured.recover() 
		if _res_type > 3:
			reduced_toxicity += 35
		else:
			health += 10
			reduced_toxicity = 150
		_devoured = null
		devoured_resources += 10
	
	# Enemy.
	if _devoured_enemy.size() > 0:
		for _enemy in _devoured_enemy:
			# Only devour enemy when dead.
			if _enemy.health <= 0:
				_enemy.queue_free()
				health += 10
				_devoured_enemy.erase(_enemy) # Removes the reference.
				devoured_enemies += 50
	
	# Item.
	if _devoured_item:
		item_collected += 1
		health += 5
		_devoured_item.recover()
		devoured_items += 100 

func lash() -> void:
	health -= lash_energy
	
	# Creates the projectile.
	var _projectile_inst = _projectile.instantiate()
	
	# Add to the tree.
	owner.objects.add_child(_projectile_inst)
	
	# Set projectile movement.
	_projectile_inst.global_position = global_position
	_projectile_inst.transform = Transform2D(get_angle_to(get_global_mouse_position()), position)
	_projectile_inst.change_texture(modulate)

func goowave() -> void:
	health -= goowave_energy
	
	# Enable fx.
	_gfx_goo.set_emitting(true)
	
	# Get all enemies in vicinity to damage.
	for _enemy in _enemies:
		_enemy.damage(5)

func death() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	_anim_blend.set_active(false)

# SIGNALS **********************************************************************
func _on_goowave_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("enemy"):
		_enemies.append(_body)

func _on_goowave_body_exited(_body: Node2D) -> void:
	if _body.is_in_group("enemy"):
		_enemies.erase(_body)

func _on_devour_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Resource") and not _body.is_in_group("Slix"):
		_devoured = _body
	elif _body.is_in_group("enemy"):
		_devoured_enemy.append(_body)
	elif _body.is_in_group("Items"):
		_devoured_item = _body

func _on_devour_body_exited(_body: Node2D) -> void:
	if _body.is_in_group("Resource") and not _body.is_in_group("Slix"):
		_devoured = null
	elif _body.is_in_group("enemy"):
		_devoured_enemy.erase(_body)
	elif _body.is_in_group("Items"):
		_devoured_item = null
