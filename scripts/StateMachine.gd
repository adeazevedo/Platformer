
var obj = null
var states = {}
var initial_state = null
var current_state = null
var args = []

func _init( obj ):
	self.obj = obj

# args:
#	state: index of dictionary, can be anything
#	callback: string with name of function
func add( state, callback ):
	self.states[state] = funcref(self.obj, callback)

func initial( state ):
	self.initial_state = state

func change_to( state, args = [] ):
	self.current_state = state
	self.args = args

func is_current_state(state):
	return self.get_current() == state

func get_current():
	return self.current_state

func get_args():
	return self.args

func execute_next():
	if self.initial_state == null: return

	if self.current_state == null:
		self.current_state = self.initial_state

	if args.size() == 0:
		self.states[self.current_state].call_func()
	else:
		self.states[self.current_state].call_func(args)
