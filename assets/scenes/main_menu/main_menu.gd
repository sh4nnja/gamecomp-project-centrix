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

# SIGNALS **********************************************************************
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/main_game/main_game.tscn")
