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

# SCENE ************************************************************************
var _scene_path: Resource = load("res://assets/scenes/main_game/main_game.tscn")

# NODES ************************************************************************
@onready var _play_btn: Label = get_node("menu/play/text")

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
# Play button.
func _on_play_pressed() -> void:
	_play_btn.set_text("Loading...")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_packed(_scene_path)

func _on_play_mouse_entered() -> void:
	_fx.play()

# About button.
func _on_about_pressed() -> void:
	_anim.play("about")

func _on_about_mouse_entered() -> void:
	_fx.play()

# Exit Button.
func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_exit_mouse_entered() -> void:
	_fx.play()

# Sound Button.
func _on_sound_toggled(_toggled_on: bool) -> void:
	for _bus in AudioServer.bus_count:
		AudioServer.set_bus_mute(_bus, _toggled_on)

func _on_sound_mouse_entered() -> void:
	_fx.play()

# About to Menu back button.
func _on_back_pressed() -> void:
	_anim.play_backwards("about")

func _on_back_mouse_entered() -> void:
	_fx.play()
