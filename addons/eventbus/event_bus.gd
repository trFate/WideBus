extends Node
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


## Dictionary referencing every listeners connexions to an emitter, the key is the emitter, the 
## value is an array of every callable connected. [br][br]
## When adding an emitter to the event bus a key in this dictionary is created with an empty array
## as a value. When a listenner is added, it will be connected to every emitter in this dictionnary
## matching filtering parameters
## Dictionary type should be key:Signal, value:Array[Callable]
var registered_emitters:Array[Emitter]

## Register the signal [param sig] as an emitter in the event bus [br][br]
## [b]Note:[/b] if the signal is already declared in [member registered_emitters] pushes a warning and return
func add_emitter(sig:Signal) -> void :
	var emitter:Emitter = _get_emitter_by_signal(sig)
	if emitter :
		push_warning("The signal ", emitter.get_name(), " on ", emitter.get_object().to_string() ," was previously added, signal should only be registered to the event bus once")
		return
	registered_emitters.append(Emitter.new(sig))

## Remove an emitter from [member registered_emitters] and disconnect every listeners still
## connected to it
func remove_emitter(sig:Signal) -> void :
	var emitter:Emitter = _get_emitter_by_signal(sig)
	if emitter :
		registered_emitters.erase(emitter)
		emitter.free()

## Register a callable as a listener to every emitter in the event bus, emitters can be filtered 
## with [param filter] similar to [method Array.filter] [br][br]
##
## [b]Exemple: [/b]
## [codeblock]
## # The listener will connect to every registered pressed signal from Button nodes
## func _ready() :
##     event_bus.add_listener_to(_on_any_button_pressed, _pressed_button_filter)
## 
## func _on_any_button_pressed() :
##     print("A button was pressed")
##
## func _pressed_button_filter(emitter) :
##     return emitter.sig.get_name() == "pressed" and emitter.sig.get_object().get_class() == "Button"
## 
## [/codeblock]
func add_listener_to(listener:Callable, filter:Callable = Callable()) -> void :
	call_deferred("_add_listener_to_deferred", listener, filter)

## Disconnect [param listener] to every registered emitter
func remove_listener(listener:Callable) -> void :
	for emitter in registered_emitters :
		emitter.remove_listener(listener)

## Return every emitter connected to [the [param listener]
func get_connected_emitters_to(listener:Callable) -> Array[Emitter] :
	return registered_emitters.filter(func(emitter:Emitter):return emitter.is_connected_to(listener))

func _add_listener_to_deferred(listener:Callable, filter:Callable = Callable()) -> void :
	var filtered_emitters:Array[Emitter]
	if filter :
		filtered_emitters = registered_emitters.filter(filter)
	else :
		filtered_emitters = registered_emitters
	for emitter in filtered_emitters :
		emitter.add_listener(listener)

func _get_emitter_by_signal(sig:Signal) -> Emitter :
	for emitter:Emitter in registered_emitters :
		if emitter.sig == sig :
			return emitter
	return

## Data representation of an emitter with its connexions to listeners
##
## Emitter stores the signal in [member sig] and every listeners connexions in [member listeners].
## When freeing the object, it disconnect [member sig] of every callable in [member listeners] 
class Emitter extends Object :

	## The signal stored as an emitter
	var sig:Signal
	## Array of every callable connected to the signal via the Emitter and EventBus classes
	var listeners:Array[Callable] = []
	
	func _init(sig_ref:Signal) -> void :
		sig = sig_ref
	
	## Add a listener to this emitter
	func add_listener(callable:Callable) -> void :
		if not listeners.has(callable) :
			sig.connect(callable)
			listeners.append(callable)
	
	## Disconnect [param listener] from this emitter
	func remove_listener(callable:Callable) -> void :
		if listeners.has(callable) :
			sig.disconnect(callable)
			listeners.erase(callable)
	
	## Disconnect all listeners from this emitter
	func remove_all_listener() -> void :
		for listener:Callable in listeners :
			sig.disconnect(listener)
		listeners = []
	
	## Return true if [param listener] is connected to this emitter
	func is_connected_to(listener:Callable) -> bool :
		return listeners.has(listener)
	
	## Overriding the [method Object.free] method to remove all listenners before freeing
	func free() -> void :
		print("custom free")
		remove_all_listener()
		super.free()
	
	func _to_string() -> String :
		return str(sig) + " -> " + str(listeners)
