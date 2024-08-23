@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("EventBus", "Node", preload("event_bus.gd"), preload("icon_flag.png"))
	add_autoload_singleton("GlobalSignal", "event_bus.gd")


func _exit_tree():
	remove_custom_type("EventBus")
	remove_autoload_singleton("GlobalSignal")
