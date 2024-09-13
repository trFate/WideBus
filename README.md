# WideBus

WideBus is a Godot plugin, adding one new node `EventBus`, it allows for a general purpose bulk signal connexions inside your project.

## Why do I need this plugin ?

If you are having trouble managing signal connexions between different scenes or if you need a quick and automatic way for connecting many signals to multiple callback functions, this plugin will provide this for you.

## How does it work ?

The EventBus node is in essence a collection of signal and call back functions (callable) that can be added, removed and filtered, once a signal is registered in the event bus one can connect any callable to them, the interest reside in the filtering part during the connexion of a call back functions, it isn't suttable for direct signal/callable connexion instead a call back function will connect to every registered signal matching the filter provided.
If the event bus is used as an autoload connecting signals can be done globally inside the project

## Basic setup and usage

After downloading the plugin it is suggested to create an autoload and assigning addons/widebus/eventbus.gd to it, lets call the autoload `GlobalSignal` for the sake of this quick tutorial.

Now it's possible to register emitters and listeners to this autoload with the method `EventBus.add_emitter()`. Let's register a `Button.pressed` and a `Button.toggles` signal to it.
```gdscript
class_name CustomButton extends Button

func _ready() -> void :
	GlobalSignal.add_emitter(pressed)
```
Now that emitter are registered, listeners can be connected to them with `EventBus.add_listener()`.
Let's create a Label and create a listenner to every pressed signal registered
```gdscript
class_name CustomLabel extends Label

func _ready() -> void :
	GlobalSignal.add_listener(_on_every_custom_button_pressed, _filter_all_signal_pressed)

func _on_every_custom_button_pressed() -> void :
	print("A custom button was pressed")

func _filter_all_signal_pressed(emitter : Emitter) -> bool :
	return emitter.sig.get_name() == "pressed" and emitter.sig.get_object().get_script().get_global_name() == "CustomButton"
```
It done ! Now every `CustomButton` in your project will connect their signal `pressed` to every `CustomLabel._on_every_custom_button_pressed()` callback function
