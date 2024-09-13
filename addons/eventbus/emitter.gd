## Data representation of an emitter with its connexions to listeners
##
## Emitter stores the signal in [member sig] and every listeners connexions in [member listeners].
## When freeing the object, it disconnect [member sig] of every callable in [member listeners] 
class_name Emitter extends Object

## The signal stored as an emitter
var sig:Signal
## Array of every callable connected to the signal via the Emitter and EventBus classes
var listeners:Array[Callable] = []

func _init(sig_ref:Signal) -> void :
	if not sig_ref :
		push_error("Attempted to create object Emitter with null signal")
		free()
		return
	if not sig_ref.get_object() :
		push_error("Attempted to create object Emitter with oprhan signal")
		free()
		return
	sig = sig_ref

func _notification(what: int) -> void :
	if what == NOTIFICATION_PREDELETE :
		remove_all_listeners()

## Add a listener to this emitter
func add_listener(callable:Callable) -> void :
	if callable and not listeners.has(callable) :
		sig.connect(callable)
		listeners.append(callable)

## Disconnect [param listener] from this emitter
func remove_listener(callable:Callable) -> void :
	if listeners.has(callable) :
		sig.disconnect(callable)
		listeners.erase(callable)

## Disconnect all listeners from this emitter
func remove_all_listeners() -> void :
	for listener:Callable in listeners :
		sig.disconnect(listener)
	listeners = []

## Return true if [param listener] is connected to this emitter
func is_connected_to(listener:Callable) -> bool :
	return listeners.has(listener)

func _to_string() -> String :
	return str(sig) + " -> " + str(listeners)
	
