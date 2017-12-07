extends Node

var ai = {
	aggressive = preload("res://ai/AggressiveBehavior.tscn"),
	#"defensive" = preload(""),
}

func instance(type):
	return ai[type.to_lower()].instance()