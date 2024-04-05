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

# Gets the main game node that has all the details.
@onready var _game: Node2D = get_parent().get_parent()

# VIRTUAL **********************************************************************
func _physics_process(_delta: float) -> void:
	set_slix_hp(_game.slix_health)
	set_slix_immun(_game.slix_immunity)

# CUSTOM ***********************************************************************
func set_slix_hp(_value: float) -> void:
	_life_prog.value = _value
	
	# Changes Slix icon appearance for UI.
	if _life_prog.value <= 100 and _life_prog.value >= 66:
		_slix_icon.modulate = Global.slix_colors[0]
	elif _life_prog.value <= 65 and _life_prog.value >= 33:
		_slix_icon.modulate = Global.slix_colors[1]
	elif _life_prog.value <= 32 and _life_prog.value >= 1:
		_slix_icon.modulate = Global.slix_colors[2]

func set_slix_immun(_value: float) -> void:
	_immunity_prog.value = _value
