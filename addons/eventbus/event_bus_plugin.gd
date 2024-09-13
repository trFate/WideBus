@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("EventBus", "Node", preload("event_bus.gd"), preload("icon_flag.png"))
	add_custom_type("Emitter", "Object", preload("emitter.gd"), preload("icon_gear.png"))


func _exit_tree():
	remove_custom_type("EventBus")
	remove_custom_type("Emitter")
