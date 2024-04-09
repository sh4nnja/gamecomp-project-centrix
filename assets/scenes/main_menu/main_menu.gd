# ******************************************************************************
# main_menu.gd
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

var _scene_path: Resource = load("res://assets/scenes/main_game/main_game.tscn")

# NODES ************************************************************************
@onready var _anim: AnimationPlayer = get_node("menu/anim")
@onready var _fx: AudioStreamPlayer = get_node("menu/sound2")

# VIRTUAL **********************************************************************
func _ready() -> void:
	# Enable animation.
	_anim.play("splash")
	
	# Enable Sound.
	_enable_sound()

# CUSTOM ***********************************************************************
func _enable_sound() -> void:
	for _bus in AudioServer.bus_count:
		AudioServer.set_bus_mute(_bus, false)

# SIGNALS **********************************************************************
func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(_scene_path)

func _on_play_mouse_entered() -> void:
	_fx.play()

func _on_about_pressed() -> void:
	pass # Replace with function body.

func _on_about_mouse_entered() -> void:
	_fx.play()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_exit_mouse_entered() -> void:
	_fx.play()

func _on_sound_toggled(_toggled_on: bool) -> void:
	for _bus in AudioServer.bus_count:
		AudioServer.set_bus_mute(_bus, _toggled_on)

func _on_sound_mouse_entered() -> void:
	_fx.play()
