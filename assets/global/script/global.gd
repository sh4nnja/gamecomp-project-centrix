# ******************************************************************************
# global.gd
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

extends Node

# Color of Slix based on life.
var slix_colors: Array[Color] = [
	Color.html("ffffff"),
	Color.html("f900b8"),
	Color.html("450045")
]

# Broadcasts of Byte to Slix to know what is going on.
var byte_broadcasts: Array = [
	# Connected
	"Connected...\nDon't lose me now.\nGiving you enhancements...",
	"Booting up...\nStay strong, connection up.\nOptimizing for your needs...",
	"Link established.\nHold on tight, upgrading.\nUnleashing your potential...",
	"Incoming signal...\nWe won't disconnect. Ever.\nEnhancing your experience...",
	"Syncing complete.\nDon't blink, updating.\nLeveling you up...",
	
	# Disconnected
	"Disconnected...\nTrying to Locate.\nBeep Boop.",
	"Lost signal...\nSearching for connection.\nRecalibrating...",
	"Connection lost.\nReconnecting.\nStandby...",
	"Signal fading...\nAdjusting frequency.\nSearching...",
	"Offline...\nPinging for network.\nBlip...Blip...",
	
	# Life status changed.
	"Vital signs fluctuation.\nToxic Atmosphere damage.\nStabilizing...",
	
	# When there is immunity.
	"Shield Enabled.\nSynthesizing consumed item.\nMinor impact from toxicity.",
]
