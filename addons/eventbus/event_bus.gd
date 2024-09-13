class_name EventBus extends Node
## Serves as an event bus managing signal connexions between scripts
##
## EventBus is a collection of signals called emitters that keep reference to callable called
## listeners, the event bus keep track of every connexion declared by [method add_listener_to] and 
## manage them. In other terms an EventBus is a centralised collection of signal, used as an 
## autoload it allows connecting signals between multiple independant scenes easily. [br][br]
##
## Since EventBus keep tracks of every emitters/listeners connexions locally, it will not 
## interfer with the traditionnal use of signal, when using [method remove_emitter] it will
## disconnect from the signal only callable connected with [method add_listener_to]. [br][br]
##
## To declare a signal as an emitter one must use [method add_emitter], to declare a callable as a
## listener the [method add_listener_to] should be used, by default a listener will connect to 
## every registered emitters, the parameter [param filter] should be used to filter out unwanted
## emitters [br][br]
## 
## [b]Basic usages : [/b][br]
## Let's connect a custom button to the event bus, we will declare the event bus as an autoload
## called [param GlobalSignal] first, then we need to register the signal [param pressed] to the
## event bus, the following code will achieve that.
## [codeblock]
## extends Button
## 
## func _ready():
##     GlobalSignal.add_emitter(pressed)
## [/codeblock]
## Now that the button signal [param pressed] is registered as an emitter we can connect listeners 
## to it. Let's create another script extending Label that will display the number of time the
## button has been pressed
## [codeblock]
## extends Label
##
## var button_press_counter : int = 0
## 
## func _ready() -> void :
##     text = str(button_press_counter)
##     GlobalSignal.add_listener_to(
##         _on_button_pressed, 
##         func(emitter:GlobalSignal.Emitter):return emitter.sig.get_name() == "pressed"
##         )
## 
## func _on_button_pressed() -> void :
##     button_press_counter += 1
##     text = str(button_press_counter)
## [/codeblock]
## 
## [b]Note:[/b] Binding arguments are not currently supported


## Array containing [class Emitter], every added emitter are store in this array.
var registered_emitters:Array[Emitter]

## Register the signal [param sig] as an emitter in the event bus [br][br]
## [b]Note:[/b] if the signal is already declared in [member registered_emitters] pushes a warning 
## and return.
func add_emitter(sig:Signal) -> void :
	var emitter:Emitter = _get_emitter_by_signal(sig)
	if emitter :
		push_warning("The signal ", emitter.get_name(), " on ", emitter.get_object().to_string() ," was previously added, signal should only be registered to the event bus once")
		return
	var new_emitter = Emitter.new(sig)
	if is_instance_valid(new_emitter) :
		registered_emitters.append(new_emitter)

## Remove an emitter from [member registered_emitters] and disconnect every listeners still
## connected to it.
func remove_emitter(emitter:Emitter) -> void:
	registered_emitters.erase(emitter)
	emitter.free()

## Remove an emitter based on its signal from [member registered_emitters] and disconnect every listeners still
## connected to it. 
func remove_emitter_from_signal(sig:Signal) -> void:
	var emitter:Emitter = _get_emitter_by_signal(sig)
	if emitter :
		registered_emitters.erase(emitter)
		emitter.free()

## Remove every emitter an object has declared.[br][br]
## This is usefull to remove every declared emitter when freeing an object from memory
func remove_emitter_from_object(object:Object) -> void :
	for emitter:Emitter in registered_emitters:
		if emitter.sig.get_object() == object :
			remove_emitter(emitter)

## Remove all emitter from [member registered_emitters]
func remove_all_emitters() -> void:
	for emitter:Emitter in registered_emitters:
		emitter.free()
	registered_emitters = []

## Clean [member registered_emitters] from emitter without a correct object (when the object was
## freed but its declared emitter wasn't removed) 
func clean_emitters() -> void :
	for emitter:Emitter in registered_emitters:
		if not is_instance_valid(emitter.sig.get_object()):
			remove_emitter(emitter)

## Register a callable as a listener to every emitter in the event bus, emitters can be filtered 
## with [param filter] similar to [method Array.filter] [br][br]
##
## [b]Exemple: [/b]
## [codeblock]
## # The listener will connect to every registered pressed signal from Button nodes
## func _ready():
##     event_bus.add_listener_to(_on_any_button_pressed, _pressed_button_filter)
## 
## func _on_any_button_pressed():
##     print("A button was pressed")
##
## func _pressed_button_filter(emitter: Emitter) -> bool:
##     return emitter.sig.get_name() == "pressed" and emitter.sig.get_object().get_class() == "Button"
## 
## [/codeblock]
func add_listener_to(listener:Callable, filter:Callable = Callable()) -> void :
	call_deferred("_add_listener_to_deferred", listener, filter)

## Disconnect [param listener] to every registered emitter
func remove_listener(listener:Callable) -> void :
	for emitter:Emitter in registered_emitters :
		emitter.remove_listener(listener)

## Return every emitter connected to [param listener]
func get_connected_emitters_to(listener:Callable) -> Array[Emitter] :
	return registered_emitters.filter(func(emitter:Emitter)->bool:return emitter.is_connected_to(listener))

func _add_listener_to_deferred(listener:Callable, filter:Callable = Callable()) -> void :	
	var filtered_emitters:Array[Emitter]
	if filter :
		filtered_emitters = registered_emitters.filter(filter)
	else :
		filtered_emitters = registered_emitters
	for emitter:Emitter in filtered_emitters :
		emitter.add_listener(listener)

func _get_emitter_by_signal(sig:Signal) -> Emitter :
	for emitter:Emitter in registered_emitters :
		if emitter.sig == sig :
			return emitter
	return
