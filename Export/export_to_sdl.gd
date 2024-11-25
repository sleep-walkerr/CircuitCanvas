extends Node
var GatesContainer
var InputsOutputsContainer
var WiresContainer
var WireConnections = []
var DataGateGridRef


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func PrintCircuit() -> void:
	print("\nCOMPONENTS")
	for gate in GatesContainer.get_children():
		print(gate.type," ", gate.name)
	print("ALIASES")
	for IOobject in InputsOutputsContainer.get_children():
		print(IOobject.name, " = ", IOobject.alias)
	
func CollectWireConnections() -> void:
	if WiresContainer != null:
		for wire in WiresContainer.get_children():
			var pin_1 = wire.get_used_cells_by_id(2, Vector2i(0,0))[0] # collecting wire pins to check what it is connecting
			var pin_2 = wire.get_used_cells_by_id(2, Vector2i(0,0))[1]
			var WireConnection = [pin_1, pin_2] # the wire connection object
			WireConnections.append(WireConnection)

func SimplifyWireConnections() -> void:
	var MatchesFound = []
	var PinMatches = [] # used to count the number of times a pin was found as a match
	
	# Algorithm step 1
	# collect all matches
	for connection in WireConnections:
			for other_connection in WireConnections:
				if other_connection != connection:
					if other_connection.has(connection[0]):
						var new_pin1 = other_connection.duplicate()
						var new_pin2 = connection.duplicate()
						new_pin1.erase(connection[0])
						new_pin2.erase(connection[0])
						var new_connection = [new_pin1[0],new_pin2[0]]
						MatchesFound.append([connection, other_connection, new_connection, connection[0]])
					if other_connection.has(connection[1]):
						var new_pin1 = other_connection.duplicate()
						var new_pin2 = connection.duplicate()
						new_pin1.erase(connection[1])
						new_pin2.erase(connection[1])
						var new_connection = [new_pin1[0],new_pin2[0]]
						MatchesFound.append([connection, other_connection, new_connection, connection[1]])
	# remove match duplicates
	for pin_match in MatchesFound:
		for other_pin_match in MatchesFound:
			# dont compare them to themselves
			if pin_match != other_pin_match:
				if other_pin_match[2].has(pin_match[2][0]) and other_pin_match[2].has(pin_match[2][1]):
					MatchesFound.erase(other_pin_match)
	# count matches for a given pin and put them in a struct
	for pin_match in MatchesFound:
		PinMatches.append(pin_match[3])
	# remove matches that remove a pin matched more than 1 time (indicates dependencies between other wires)
	var FilteredMatches = []
	for pin_match in MatchesFound:
		#print(pin_match, "count:",PinMatches.count(pin_match[3]))
		if PinMatches.count(pin_match[3]) < 2:
			FilteredMatches.append(pin_match)
	MatchesFound = FilteredMatches
	# first simplification of wires using matches
	var TempWireConnections = WireConnections.duplicate()
	for pin_match in MatchesFound:
		# if wires havent been replaced yet, replace according to pin_match entry
		if WireConnections.has(pin_match[0]) and WireConnections.has(pin_match[1]):
			var simplified_wire = pin_match[2]
			print("simplified wire:", simplified_wire)
			# check other matches/simplifications for the pin erased
			for other_pin_match in MatchesFound:
				var pin_deleted = pin_match[3]
				var bad_pin
				var good_pin
				if pin_match != other_pin_match:
					if other_pin_match[0].has(pin_deleted):
						bad_pin = other_pin_match[0]
						bad_pin.erase(pin_deleted)
						bad_pin = bad_pin[0]
						# take other wire and erase bad pin from it to get the good pin
						good_pin = other_pin_match[1]
						good_pin.erase(bad_pin)
						good_pin = good_pin[0]
						# find bad pin in simplified_wire
						simplified_wire.erase(bad_pin)
						simplified_wire.append(good_pin)
						WireConnections.erase(other_pin_match[0])
						WireConnections.erase(other_pin_match[1])
						print("pin_deleted",pin_deleted," bad_pin:",bad_pin,"good_pin:",good_pin)
					elif other_pin_match[1].has(pin_deleted):
						bad_pin = other_pin_match[1]
						bad_pin.erase(pin_deleted)
						bad_pin = bad_pin[1]
						good_pin = other_pin_match[0]
						good_pin.erase(bad_pin)
						good_pin = good_pin[0]
						# find bad pin in simplified_wire
						simplified_wire.erase(bad_pin)
						simplified_wire.append(good_pin)
						WireConnections.erase(other_pin_match[0])
						WireConnections.erase(other_pin_match[1])
						print("pin_deleted",pin_deleted," bad_pin:",bad_pin,"good_pin:",good_pin)
			print("simplified wire after changes:", simplified_wire)
			WireConnections.erase(pin_match[0])
			WireConnections.erase(pin_match[1])
			WireConnections.append(simplified_wire)
	 
	#print("matches list:")
	#for pin_match in MatchesFound:
		#print(pin_match, PinMatches.count(pin_match[3]))
	#print("end list")
	
	print("wire connections final:")
	for wire_connection in WireConnections:
		print(wire_connection)
