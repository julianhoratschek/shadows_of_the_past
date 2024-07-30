extends Control


## What we are doing right now
enum LabelState {
	## Printing to the screen
	Printing,
	
	## Waiting for user input
	Waiting,
	
	## Nothing more to print
	Done
}

## Frame time between two letters
const PrintTime := 0.06

## Frame time between blinks at the end of a line
const WaitTime := 0.6

## Current time, changes depending on _state and changes made to variable
## (e.g. sped up text)
var _print_timer := PrintTime:
	get:
		return _print_timer if _state == LabelState.Printing else WaitTime
	set(value):
		_print_timer = value

## Counter for printing/blinking
var _print_counter := 0.0

## Current state
var _state := LabelState.Printing

## Index of currently displayed text
var _paragraph_index := 0

## Indicates on/off of blinking at end of line
var _blinker := -1

## Paragraphs
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


## Start label off with first paragraph
func _ready():
	label.text = _paragraphs[_paragraph_index]


## Print text letter by letter during Printing-state, or blink letter at
## end of line during Wait-State
func _process(delta):
	
	# Guards with timer
	_print_counter += delta
	if _print_counter < _print_timer:
		return
	_print_counter -= _print_timer
	
	# Check current state
	match _state: 
		
		# Still printing to screen
		LabelState.Printing:
			
			# Show more characters
			label.visible_characters += 1
			
			# If we are done with the line
			if label.visible_ratio == 1.0:
				
				# Read next line if available
				_paragraph_index += 1
				if _paragraph_index < _paragraphs.size():
					
					# Set state to waiting
					_state = LabelState.Waiting
					
					# Append blinking character at end of line
					label.text += "¶"
					_blinker = -1
				
				# If no more lines are available we are done
				else:
					_state = LabelState.Done
		
		# If current state is waiting
		LabelState.Waiting:
			
			# Blink our last character in line
			label.visible_characters -= 1 * _blinker
			_blinker *= -1


## During Printing state speed up text if any key is pressed, during Waiting state
## progress on button press to next text line
func _input(event: InputEvent):
	
	# User can press any key
	if event.is_pressed():
		
		match _state:
			
			# When we are currently printing
			LabelState.Printing:
				
				# Speed up text
				# _print_timer = 0.04
				pass
				
			# When we are currently waiting
			LabelState.Waiting:
				# Reset label visibility
				label.visible_ratio = 0.0
				
				# Update text
				label.text = _paragraphs[_paragraph_index]
				
				# Set current state
				_state = LabelState.Printing
				_print_counter = 0.0
				
			LabelState.Done:
				# TODO to main menu?
				pass
	
	# If we release a key during printing, reset text speed to normal
	# elif event.is_released() and _state == LabelState.Printing:
	# 	_print_timer = PrintTime
