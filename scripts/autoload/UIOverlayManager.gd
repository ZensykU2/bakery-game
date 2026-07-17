extends Node

const OVERLAY_GROUP := &"ui_overlay"


func close_all_overlays(except: Node = null) -> void:
	for overlay in get_tree().get_nodes_in_group(OVERLAY_GROUP):
		if overlay == except or not is_instance_valid(overlay):
			continue
		if overlay.has_method("close_overlay"):
			overlay.close_overlay()
		elif overlay is CanvasItem:
			overlay.visible = false


func close_active_overlay() -> bool:
	var overlays := get_tree().get_nodes_in_group(OVERLAY_GROUP)
	for index in range(overlays.size() - 1, -1, -1):
		var overlay := overlays[index]
		if not is_instance_valid(overlay) or not _is_overlay_open(overlay):
			continue

		if overlay.has_method("close_overlay"):
			overlay.close_overlay()
		elif overlay is CanvasItem:
			overlay.visible = false
		return true
	return false


func _is_overlay_open(overlay: Node) -> bool:
	if overlay.has_method("is_overlay_open"):
		return overlay.is_overlay_open()
	return overlay is CanvasItem and overlay.visible
