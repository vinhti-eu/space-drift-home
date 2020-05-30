extends Node2D

var distance = 0
var sceen_width_minus_ship_length = 300
var pixel_speed_per_frame = 0.04
var dict = {}
var ship_y_position = 0
var ship_moves_up = true
var mission_data
var mission_text = ""
var mission_event1
var mission_event2
var mission_event3
var mission_answer_text1 = ""
var mission_answer_text2 = ""
var mission_answer_text3 = ""
var timer
var current_mission_probability = 0.05
onready var volume = get_node("Tween")

func _ready():
	
	volume.interpolate_property(get_node("BackgroundMusic"),"volume_db",-20, 0,1.2,Tween.TRANS_SINE,Tween.EASE_IN)
	volume.start()

	randomize()
	change_and_hide_text_box()
	
	parse_mission_json()
	start_new_mission_timer()

	



func generate_mission_dialogue():
	var mission = generate_mission()
	print(mission.MissionName)	
	mission_text = mission.Text
	
	var answers = generate_answers(mission)

	mission_answer_text1 = answers[0].Text
	if(answers.size()>1):
		mission_answer_text2 = answers[1].Text
	if(answers.size()>2):	
		mission_answer_text3 = answers[2].Text
	
	if(answers.size()>0 and answers[0].Event != null):	
		mission_event1 = answers[0].Event
	if(answers.size()>1 and answers[1].Event != null):	
		mission_event2 = answers[1].Event	
	if(answers.size()>2 and answers[2].Event != null ):	
		mission_event3 = answers[2].Event
		
		
	for answer in answers:
		print(answer.Text)
		print(answer.Event)
	
func start_new_mission_timer():
	timer = Timer.new()
	timer.wait_time = 4
	timer.one_shot = false
	self.add_child(timer)
	timer.start()
	timer.connect("timeout",self,"mission_tick")
	
	
func mission_tick():
	current_mission_probability 
	if(randf() < current_mission_probability):
		timer.queue_free()
		generate_mission_dialogue()#these should be called
		show_mission()             #in a mission generator instead
		print("mission has been generated with probability: "+str(current_mission_probability))
	else: 
		current_mission_probability = current_mission_probability * 1.5
	print("tick, new mission probability: " + str(current_mission_probability))
	

func parse_mission_json():
	var mission_data_file = File.new()
	mission_data_file.open("res://invisibleData/mission_dialogue.json", File.READ)
	var mission_data_json = JSON.parse(mission_data_file.get_as_text())
	mission_data_file.close()
	mission_data = mission_data_json.result
	

func change_and_hide_text_box():
	get_node("TextDialogue/TextBox").modulate = Color(1, 1, 1, 0.5)
	get_node("TextDialogue").hide()

func generate_mission():
	var possible_missions = []
	var temp_missions = []
	var weighted_missions = []
	for id in mission_data:
		if(  int(id) % 10 == 0):
				possible_missions.append(mission_data[id])
	for i in possible_missions:
			temp_missions.append([i,i.Weight])
	for i in temp_missions:
		while i[1] > 0: #i[1] is the weight of the mission name
			weighted_missions.append(i[0]) #generates a list of mission names
			i[1] = i[1] -1 	
	weighted_missions.shuffle()		
	return weighted_missions[0]
	#for i in possible_missions:
	
func generate_answers(mission):
	var answers = []
	var generated_answers = []
	for i in range(mission.MissionID+1,mission.MissionID+10,1):
			answers.append(i)
	for id in mission_data:	
		for i in answers:
			if id == str(i):
				generated_answers.append(mission_data[id])
		
	return generated_answers
		
		
func show_mission():	
	get_node("TextDialogue").show()
	get_node("TextDialogue/MissionTextBox").text = mission_text
	get_node("TextDialogue/Text1").text = mission_answer_text1
	get_node("TextDialogue/Text2").text = mission_answer_text2
	get_node("TextDialogue/Text3").text = mission_answer_text3
	if mission_answer_text1 == "":
		get_node("TextDialogue/Answer1").hide()#must use autofinish text when answer 1 is empty
	if mission_answer_text2 == "":
		get_node("TextDialogue/Answer2").hide()
	if mission_answer_text3 == "":
		get_node("TextDialogue/Answer3").hide()	
	

func button_on_hover():
	if(get_node("TextDialogue/Answer1").is_hovered()):
		get_node("TextDialogue/Text1").modulate = Color(0.95, 1, 0, 1)
	else: 	
		get_node("TextDialogue/Text1").modulate = Color(1, 1, 1)	
		
	if(get_node("TextDialogue/Answer2").is_hovered()):
		get_node("TextDialogue/Text2").modulate = Color(0.95, 1, 0, 1)
	else: 	
		get_node("TextDialogue/Text2").modulate = Color(1, 1, 1)	
		
	if(get_node("TextDialogue/Answer3").is_hovered()):
		get_node("TextDialogue/Text3").modulate = Color(0.95, 1, 0, 1)
	else: 	
		get_node("TextDialogue/Text3").modulate = Color(1, 1, 1)
		
func _process(delta):
	button_on_hover()
	
	if(get_node("Position2D").position.x<sceen_width_minus_ship_length):
		get_node("Position2D").position.x =get_node("Position2D").position.x+ pixel_speed_per_frame
	
	
	if(ship_y_position>6):
		ship_moves_up = false
	if(ship_y_position < -6):
		ship_moves_up = true
	if(ship_moves_up):
		ship_y_position = ship_y_position +0.1
	else: ship_y_position = ship_y_position -0.1
	get_node("PositionOfShip").position.y  = ship_y_position
	

func _on_Answer1_button_down():
	print("button1 pressed")
	print("event that should be activated is: " + str(mission_event1))
	var path = "res://stages/" + str(mission_event1)+ ".tscn"
	get_tree().change_scene(path)

func _on_Answer2_button_down():
	print("button2 pressed")
	print("event that should be activated is: " + str(mission_event1))
	var path = "res://stages/" + str(mission_event2)+ ".tscn"
	get_tree().change_scene(path)

func _on_Answer3_button_down():
	print("button3 pressed")
	print("event that should be activated is: " + str(mission_event1))
	var path = "res://stages/" + str(mission_event3)+ ".tscn"
	get_tree().change_scene(path)
