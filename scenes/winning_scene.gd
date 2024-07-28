extends Control


enum LabelState {
	Printing,
	Waiting,
	Done
}

const PrintTime := 0.06
const WaitTime := 0.6

var _print_timer := PrintTime:
	get:
		return _print_timer if _state == LabelState.Printing else WaitTime
	set(value):
		_print_timer = value

var _print_counter := 0.0

var _state := LabelState.Printing
var _paragraph_index := 0
var _blinker := -1

var _paragraphs := [
	"so you stayed true to yourself",
	"ironic...", 
	"after all you have done",
	"just to rid yourself of me",
	"but now",
	"that we are whole again",
	"did I really escape?",
	"THE END"
]


@onready var label := $PanelContainer/MarginContainer/Label

func _ready():
	label.text = _paragraphs[_paragraph_index]

func _process(delta):
	_print_counter += delta
	if _print_counter < _print_timer:
		return
	_print_counter -= _print_timer
			
	match _state: 
		LabelState.Printing:		
			label.visible_characters += 1
			if label.visible_ratio == 1.0:
				_paragraph_index += 1
				if _paragraph_index < _paragraphs.size():
					_state = LabelState.Waiting
					label.text += "¶"
					_blinker = -1
				else:
					_state = LabelState.Done
		
		LabelState.Waiting:
			label.visible_characters -= 1 * _blinker
			_blinker *= -1
			

func _input(event: InputEvent):
	if event.is_pressed():
		match _state:
			LabelState.Printing:
				_print_timer = 0.04
				
			LabelState.Waiting:
				label.visible_ratio = 0.0
				label.text = _paragraphs[_paragraph_index]
				_state = LabelState.Printing
				
			LabelState.Done:
				# TODO to main menu
				pass
				
	elif event.is_released() and _state == LabelState.Printing:
		_print_timer = PrintTime
