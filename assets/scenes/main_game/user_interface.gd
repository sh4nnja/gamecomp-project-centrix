# ******************************************************************************
# user_interface.gd
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

extends Control

# NODES ************************************************************************
@onready var _life_prog: TextureProgressBar = get_node("stats/life_progress")
@onready var _immunity_prog: TextureProgressBar = get_node("stats/immunity_progress")
@onready var _slix_icon: TextureRect = get_node("stats/slix")

@onready var _shield_overlay: TextureRect = get_node("shield_overlay")

@onready var _byte_icon: TextureRect = get_node("byte_notif/byte")
@onready var _byte_broadcast: Label = get_node("byte_notif/byte_panel/byte_broadcast")
@onready var _byte_panel: TextureRect = get_node("byte_notif/byte_panel")
@onready var _byte_help_panel: TextureRect = get_node("byte_notif/help_panel")

@onready var _ui_anim: AnimationPlayer = get_node("user_interface_anim")

# Gets the main game node that has all the details.
@onready var _game: Node2D = get_parent().get_parent()

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _death: bool = false

# VIRTUAL **********************************************************************
func _ready() -> void:
	_set_cursor()
	_byte_connected()

func _physics_process(_delta: float) -> void:
	_set_slix_hp(_game.slix_health)
	_set_slix_immun(_game.slix_immunity)
	_death_animation(_game.slix_health)
	
	_pause()
	_byte_connected()

# CUSTOM ***********************************************************************
# Set custom cursor.
func _set_cursor() -> void:
	Input.set_custom_mouse_cursor(load("res://assets/objects/user_interface/textures/in_game/cursor.png"))

# Set up Slix's health to UI
func _set_slix_hp(_value: float) -> void:
	_life_prog.value = _value
	
	# Changes Slix icon appearance for UI.
	if _life_prog.value <= 100 and _life_prog.value >= 66:
		_slix_icon.modulate = Global.slix_colors[0]
	elif _life_prog.value <= 65 and _life_prog.value >= 33:
		_slix_icon.modulate = Global.slix_colors[1]
	elif _life_prog.value <= 32 and _life_prog.value >= 1:
		_slix_icon.modulate = Global.slix_colors[2]

# Whenever Slix has immunity granted.
func _set_slix_immun(_value: float) -> void:
	_immunity_prog.value = _value
	if _value > 0:
		# Checks if shield texture is not visible to trigger the event once.
		if not _shield_overlay.get("visible"):
			_byte_panel.get_texture().set_region(Rect2(252, 0, 126, 28))
			_byte_help_panel.get_texture().set_region(Rect2(128, 0, 64, 64))
		_shield_overlay.show()
	else:
		if _shield_overlay.get("visible"):
			# Checks if byte is nearby.
			if _byte_icon.get("visible"):
				_byte_panel.get_texture().set_region(Rect2(0, 0, 126, 28))
				_byte_help_panel.get_texture().set_region(Rect2(0, 0, 64, 64))
			else:
				_byte_panel.get_texture().set_region(Rect2(126, 0, 126, 28))
				_byte_help_panel.get_texture().set_region(Rect2(64, 0, 64, 64))
		_shield_overlay.hide()

# Whenever life changes.
func _randomize_life_fluctuation() -> void:
	if _game.byte_connected:
		_rng.randomize()
		_byte_broadcast.text = Global.byte_broadcasts[10]

# Whenever there is damage decrease.
func _randomize_life_min_deduction() -> void:
	if _game.byte_connected:
		_rng.randomize()
		_byte_broadcast.text = Global.byte_broadcasts[11]

# Sets all of Byte's panel whenever connected.
func _byte_connected() -> void:
	if _game.byte_connected:
		# Checks if byte is near.
		if not _byte_icon.get("visible"):
			# Checks if shield texture is visible.
			if _shield_overlay.get("visible"):
				_byte_panel.get_texture().set_region(Rect2(252, 0, 126, 28))
				_byte_help_panel.get_texture().set_region(Rect2(128, 0, 64, 64))
			else:
				_byte_broadcast.text = Global.byte_broadcasts[_rng.randi_range(0, 4)]
				_byte_panel.get_texture().set_region(Rect2(0, 0, 126, 28))
				_byte_help_panel.get_texture().set_region(Rect2(0, 0, 64, 64))
		_byte_icon.show()
	else:
		if _byte_icon.get("visible"):
			_byte_broadcast.text = Global.byte_broadcasts[_rng.randi_range(5, 9)]
			_byte_panel.get_texture().set_region(Rect2(126, 0, 126, 28))
			_byte_help_panel.get_texture().set_region(Rect2(64, 0, 64, 64))
		_byte_icon.hide()

func _death_animation(_value: float) -> void:
	# Dead.
	if _value <= 0 and not _death:
		_death = true
		_ui_anim.play("death")

func _pause_animation(_value: bool) -> void:
	if _value:
		_ui_anim.play("pause")
	else:
		_ui_anim.play_backwards("pause")
	
	# Pause the tree.
	get_tree().paused = _value

func _pause() -> void:
	if Input.is_action_just_pressed("esc") and not _death:
		if not get_tree().paused:
			_pause_animation(true)
		else:
			_pause_animation(false)

# SIGNALS **********************************************************************
func _on_life_progress_value_changed(_value: float) -> void:
	_randomize_life_fluctuation()

func _on_immunity_progress_value_changed(_value: float) -> void:
	_randomize_life_min_deduction()
