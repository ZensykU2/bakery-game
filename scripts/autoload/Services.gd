extends Node

# Active service instances (Service Locator Pattern)
var game: Node = null
var inventory: Node = null
var baking: Node = null
var crafting: Node = null
var scene: Node = null
var time: Node = null

func is_ready() -> bool:
	return game != null and inventory != null and baking != null and crafting != null and scene != null
