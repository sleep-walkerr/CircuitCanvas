extends Node
var GatesContainer
var InputsOutputsContainer
var WiresContainer
var WireConnections = []
var DataGateGridRef
var MatchesFound = []
var CompleteConnections = [] # holds final connections which ignore the wire and just include the two objects that are connected
var gate_grid_data_ref


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
	print("CONNECTIONS")
	for connection in CompleteConnections:
		print(connection)

func CollectWireConnections() -> void:
	if WiresContainer != null:
		for wire in WiresContainer.get_children():
			var pin_1 = wire.get_used_cells_by_id(2, Vector2i(0,0))[0] # collecting wire pins to check what it is connecting
			var pin_2 = wire.get_used_cells_by_id(2, Vector2i(0,0))[1]
			var WireConnection = [pin_1, pin_2] # the wire connection object
			WireConnections.append(WireConnection)




func SimplifyWireConnections() -> void:
	
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
			# check other matches/simplifications for the pin erased
			for other_pin_match in MatchesFound: # this looks for match conflicts with the current match, and handles those matches appropriately
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
					elif other_pin_match[1].has(pin_deleted):
						bad_pin = other_pin_match[1]
						bad_pin.erase(pin_deleted)
						bad_pin = bad_pin[0]
						good_pin = other_pin_match[0]
						good_pin.erase(bad_pin)
						good_pin = good_pin[0]
						# find bad pin in simplified_wire
						simplified_wire.erase(bad_pin)
						simplified_wire.append(good_pin)
						WireConnections.erase(other_pin_match[0])
						WireConnections.erase(other_pin_match[1])
			WireConnections.erase(pin_match[0])
			WireConnections.erase(pin_match[1])
			WireConnections.append(simplified_wire)
	# END STEP 1 IN ALGORITHM
	# ***********************************************************************************************
	
	
	
	
	
	
	# ALGORITHM STEP 2
	# make list with all pins that are making contact with a gate or input/output
	var ContactPins = []
	for wire_connection in WireConnections:
		for pin in wire_connection:
			# if pin is making contact with a gate pin
			if GatesContainer.get_cell_source_id(pin) == 8 or GatesContainer.get_cell_source_id(pin) == 7:
				ContactPins.append(pin)
			# if pin is making contact with any input or output pin
			for IOObject in InputsOutputsContainer.get_children():
				if IOObject.get_cell_source_id(pin) == 3:
					ContactPins.append(pin)
	# Generate a new list of matches, matches cannot be added if their wires contain a pin inside of ContactPins
	MatchesFound.clear()
	PinMatches.clear()
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
						#if both new pins are in the ContactPins list, dont allow the match
						if !ContactPins.has(new_pin1[0]) and !ContactPins.has(new_pin2[0]):
							MatchesFound.append([connection, other_connection, new_connection, connection[0]])
					if other_connection.has(connection[1]):
						var new_pin1 = other_connection.duplicate()
						var new_pin2 = connection.duplicate()
						new_pin1.erase(connection[1])
						new_pin2.erase(connection[1])
						var new_connection = [new_pin1[0],new_pin2[0]]
						#if both new pins are in the ContactPins list, dont allow the match
						if !ContactPins.has(new_pin1[0]) and !ContactPins.has(new_pin2[0]):
							MatchesFound.append([connection, other_connection, new_connection, connection[1]])
	# remove match duplicates
	for pin_match in MatchesFound:
		for other_pin_match in MatchesFound:
			# dont compare them to themselves
			if pin_match != other_pin_match:
				if other_pin_match[2].has(pin_match[2][0]) and other_pin_match[2].has(pin_match[2][1]):
					MatchesFound.erase(other_pin_match)
					
					
					
	# PREVIOUS SECTION		
	# count matches for a given pin and put them in a struct
	for pin_match in MatchesFound:
		PinMatches.append(pin_match[3])
	# count the PinMatches and order them by occurrence
	var pin_matches_by_occurance = []
	var pin_occurrance_mask = []
	var pin_occurance_final = []
	for pin_match in MatchesFound: # get unique pin_matches
		if !pin_matches_by_occurance.has(pin_match[3]):
			pin_matches_by_occurance.append(pin_match[3])
	# collect # of times each pin occurrs in a match
	for pin_match in pin_matches_by_occurance:
		pin_occurrance_mask.append(PinMatches.count(pin_match))
	pin_occurrance_mask.sort()
	# replace each # with its respective pin match
	for pin_occurance_number in pin_occurrance_mask:
		for pin_match in pin_matches_by_occurance:
			if PinMatches.count(pin_match) == pin_occurance_number:
				pin_occurance_final.append([pin_match, pin_occurance_number])
				break
	pin_occurance_final.reverse()
	#print("pin occurance final:", pin_occurance_final)
	#for matched_pin in pin_occurance_final:
		#for proposed_match in MatchesFound:
			##if proposed_match[0].has(matched_pin[0]) or 
			#pass
	
	
	
	# MIGHT NOT NEED PREVIOUS SECTION

	# second simplification using matches, this time condensing wires instead of combining them using recursion
	for pin_match in MatchesFound:
		CondenseWires(pin_match)
		MatchesFound.erase(pin_match)
		FindConflicts(pin_match)
	
	
	# Make final version of connections after connections have all been made direct
	MakeFinalConnections()
	
	
	print("matches list:")
	for pin_match in MatchesFound:
		print(pin_match," ", PinMatches.count(pin_match[3]))
	print("end list")
	
	print("wire connections final:")
	for wire_connection in WireConnections:
		print(wire_connection)

func CondenseWires(pin_match): # condenses wires to the pin match within the match entry
	var LeftPin = pin_match[2][0]
	var RightPin = pin_match[2][1]
	var CenterPin = pin_match[3]
	# erase original wires
	WireConnections.erase(pin_match[0])
	WireConnections.erase(pin_match[1])
	for wire in WireConnections:
		if wire.has(LeftPin):
			wire.erase(LeftPin)
			wire.append(CenterPin)
		if wire.has(RightPin):
			wire.erase(RightPin)
			wire.append(CenterPin)
			
func ConflictCondense(pin_match,pin): # replaces all three pins with the desired center pin
	var LeftPin = pin_match[2][0]
	var RightPin = pin_match[2][1]
	var CenterPin = pin_match[3]
	
	# erase original wires
	WireConnections.erase(pin_match[0])
	WireConnections.erase(pin_match[1])
	for wire in WireConnections:
		if wire.has(LeftPin):
			wire.erase(LeftPin)
			wire.append(pin)
		if wire.has(RightPin):
			wire.erase(RightPin)
			wire.append(pin)
		if wire.has(CenterPin):
			wire.erase(CenterPin)
			wire.append(pin)
			
func FindConflicts(pin_match):
	var LeftPin = pin_match[2][0]
	var RightPin = pin_match[2][1]
	var CenterPin = pin_match[3]
	for other_pin_match in MatchesFound:
		if other_pin_match != pin_match:
			if other_pin_match[0].has(LeftPin) or other_pin_match[0].has(RightPin):
				ConflictCondense(other_pin_match,CenterPin)
				FindConflicts(other_pin_match)
				MatchesFound.erase(other_pin_match)
			if other_pin_match[1].has(LeftPin) or other_pin_match[1].has(RightPin):
				ConflictCondense(other_pin_match,CenterPin)
				FindConflicts(other_pin_match)
				MatchesFound.erase(other_pin_match)
				
func GetGateByTile(tile) -> Node2D: # This needs to be updated
	if gate_grid_data_ref.has(tile):
		return gate_grid_data_ref.get(tile).managing_node_ref
	else: return null
	
func GetInputOutputByTile(tile) -> TileMapLayer: # Gets the input_output at the given tile
	for input_output in $InputOutputContainer.get_children():
		for used_tile in input_output.get_used_cells():
			if input_output.get_cell_source_id(tile) != -1:
				if tile == used_tile:
					return input_output
	return null

func MakeFinalConnections():
	for connection in WireConnections:
		var final_connection = []
		var component_strings = []
		var final_string = ""
		for pin in connection: 
			if GatesContainer.get_cell_source_id(pin) == 7: # if its an input
				var gate = GetGateByTile(pin)
				var pin_number = gate.gate_inputs[pin]
				final_connection.append(gate.name)
				final_connection.append(pin_number)
				component_strings.append(str(gate.name,"#",pin_number))
			if GatesContainer.get_cell_source_id(pin) == 8: # if its an output
				var gate = GetGateByTile(pin)
				var pin_number = gate.gate_inputs.size()+1
				final_connection.append(gate.name)
				final_connection.append(pin_number) 
				component_strings.append(str(gate.name,"#",pin_number))
			# if pin is making contact with any input or output pin
			for IOObject in InputsOutputsContainer.get_children():
				if IOObject.get_cell_source_id(pin) == 3:
					component_strings.append(IOObject.name)
		final_string = str(component_strings[0]," - ",component_strings[1])
		CompleteConnections.append(final_string)
				
