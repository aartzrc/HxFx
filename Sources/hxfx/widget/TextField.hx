package hxfx.widget;

import kha.Scheduler;
import kha.input.KeyCode;

@:bindable
class TextField extends Text {
	
	@:bindable
	var _startHighlightChar:Int = -1;
	@:bindable
	var _endHighlightChar:Int = -1;
	@:bindable
	var _cursorPos:Int = -1;
	
	var _cursorBlinkTask:Int = -1;
	var _cursorBlinkState:Bool = false;

	public function new() {
		super();

		//mouseSubscribe = true;
		settings.cursor = "text"; // Default to the text selection cursor
		
		// Bind to mouse
		Bind.bind(this.mouseData.b1down, _mouseb1Down);
		Bind.bind(this.mouseData.b1doubleclicked, _mouseb1DblClicked);
		Bind.bindAll(this.mouseData, _mouseChanged);

		// Bind/react to highlight changes
		Bind.bind(this._startHighlightChar, _highlightChanged);
		Bind.bind(this._endHighlightChar, _highlightChanged);

		// Bind/react to cursor position
		Bind.bind(this._cursorPos, _cursorPos_Changed);
	}

	private function _highlightChanged(from:Int, to:Int) {
		layoutIsValid = false;
	}

	private function _cursorPos_Changed(from:Int, to:Int) {
		layoutIsValid = false;
		if(to == -1 && _cursorBlinkTask >= 0) {
			kha.Scheduler.removeTimeTask(_cursorBlinkTask);
			_cursorBlinkTask = -1;
		} else if(_cursorBlinkTask == -1) {
			_cursorBlinkTask = kha.Scheduler.addTimeTask(_cursorBlink, 0, .5);
		}
	}

	private function _cursorBlink() {
		_cursorBlinkState = !_cursorBlinkState; // Toggle blink
		layoutIsValid = false; // Redraw - a bit heavy-handed for a cursor blink..
	}

	var dragStart:Position;
	var dragCurrent:Position;
	private function _mouseb1Down(from:Bool, to:Bool) {
		if(to && mouseData.mouseInBounds) {
			// Button down and inside bounds, start tracking drag
			if(dragStart == null) {
				dragStart = new Position({x: this.mouseData.x, y: this.mouseData.y });
			}
			// Get focus
			focused = true;
		} else if(to) { // Clicked out of bounds, clear highlight
			_startHighlightChar = -1;
			_endHighlightChar = -1;
			_cursorPos = -1;
			// Clear focus
			focused = false;
		} else { // Button up, drag has stopped
			dragStart = null;
		}
	}

	private function _mouseb1DblClicked(from:Bool, to:Bool) {
		if(to && mouseData.mouseInBounds) {
			// Get the left position
			var _newPos = _cursorPos;
			while(_newPos>=0 && Text.wordWrapCharacters.indexOf(charCodes[_newPos]) == -1) _newPos--;
			if(_newPos<0) _newPos = 0;
				else _newPos++;
			_startHighlightChar = _newPos;
			
			// Get the right position
			_newPos = _cursorPos;
			while(_newPos<=charCodes.length && Text.wordWrapCharacters.indexOf(charCodes[_newPos]) == -1) _newPos++;
			if(_newPos>charCodes.length) _newPos = charCodes.length;
			_endHighlightChar = _newPos;

			_cursorPos = _endHighlightChar;
		}
	}
	
	private function _mouseChanged(origin:IBindable, name:String, from:Dynamic, to:Dynamic) {
		if(mouseData.b1down && dragStart != null && !mouseData.b1doubleclicked) { // Button down and we have a start drag location, monitor and calculate highlighting
			if(dragCurrent == null) {
				dragCurrent = new Position({x: this.mouseData.x, y: this.mouseData.y });
			} else {
				dragCurrent.x = this.mouseData.x;
				dragCurrent.y = this.mouseData.y;
			}

			// Limit mouse location to bounds of field
			if(dragCurrent.x < 0) dragCurrent.x = 0;
			if(dragCurrent.y < 0) dragCurrent.y = 0;
			if(dragCurrent.x > size.w) dragCurrent.x = size.w;
			if(dragCurrent.y > size.h) dragCurrent.y = size.h;
			
			// Calculate characters selected
			for(i in 0 ... characterRects.length) {
				var r = characterRects[i];
				var inBoundsRelativeStart = r.inBoundsRelative(dragStart);
				var inBoundsRelativeCurrent = r.inBoundsRelative(dragCurrent);
				if(inBoundsRelativeStart.x>0 && inBoundsRelativeStart.x<=.5 && inBoundsRelativeStart.y>=0 && inBoundsRelativeStart.y<=1) {
					_startHighlightChar = i;
				}
				if(inBoundsRelativeStart.x>.5 && inBoundsRelativeStart.x<=1) {
					_startHighlightChar = i+1;
				}
				if(inBoundsRelativeCurrent.x>0 && inBoundsRelativeCurrent.x<=.5) {
					_endHighlightChar = i;
				}
				if(inBoundsRelativeCurrent.x>.5 && inBoundsRelativeCurrent.x<=1) {
					_endHighlightChar = i+1;
				}
			}
			_cursorPos = _endHighlightChar;
		}
	}

	override private function _keyPressed(k:String) {
		if(k == null) return; // Ignore key up event
		
		if(highlighted) {
			_spliceText(_startHighlightChar, _endHighlightChar);
		}

		// Update text
		if(_cursorPos >= 0 && _cursorPos <= text.length) {
			var s1 = text.substr(0, _cursorPos);
			var s2 = text.substr(_cursorPos);
			text = s1 + k + s2;
			_cursorPos+=k.length;
		}
	}

	override private function _keysDownChange(keysDown:List<KeyCode>) {
		// Capture 'chord' combinations
		var control = false;
		var shift = false;
		var alt = false;
		
		// TODO: WordWrap positions could be stored during charCodes update instead of the seek routines...

		for(k in keysDown) {
			switch(k) {
				case KeyCode.Control:
					control = true;
				case KeyCode.Shift:
					shift = true;
				case KeyCode.Alt:
					alt = true;
				case _:
					// Any other things to track?
			}
		}
		
		if(highlighted) {
			for(k in keysDown) {
				switch(k) {
					case KeyCode.Left if (control && shift): // Ctrl + shift + left
						if(_startHighlightChar == -1 ) _startHighlightChar = _cursorPos;
						var _newPos = _cursorPos-2;
						while(_newPos>=0 && Text.wordWrapCharacters.indexOf(charCodes[_newPos]) == -1) _newPos--;
						if(_newPos<0) _newPos = 0;
							else _newPos++;
						_cursorPos = _newPos;
						_endHighlightChar = _cursorPos;
						_cursorBlinkState = true;
					case KeyCode.Right if (control && shift): // Ctrl + shift + right
						if(_startHighlightChar == -1 ) _startHighlightChar = _cursorPos;
						var _newPos = _cursorPos+1;
						while(_newPos<=charCodes.length && Text.wordWrapCharacters.indexOf(charCodes[_newPos]) == -1) _newPos++;
						if(_newPos>charCodes.length) _newPos = charCodes.length;
						_cursorPos = _newPos;
						_endHighlightChar = _cursorPos;
						_cursorBlinkState = true;
					case KeyCode.Left if (shift): // Shift + left
						if(_startHighlightChar == -1 ) _startHighlightChar = _cursorPos;
						if(_cursorPos>0) _cursorPos--;
						_endHighlightChar = _cursorPos;
						_cursorBlinkState = true;
					case KeyCode.Right if (shift): // Shift + right
						if(_startHighlightChar == -1 ) _startHighlightChar = _cursorPos;
						if(_cursorPos<text.length) _cursorPos++;
						_endHighlightChar = _cursorPos;
						_cursorBlinkState = true;
					case KeyCode.Left:
						if(_startHighlightChar<_endHighlightChar) _cursorPos = _startHighlightChar;
							else _cursorPos = _endHighlightChar;
						clearHighlight();
						_cursorBlinkState = true;
					case KeyCode.Right:
						if(_startHighlightChar>_endHighlightChar) _cursorPos = _startHighlightChar;
							else _cursorPos = _endHighlightChar;
						clearHighlight();
						_cursorBlinkState = true;
					case KeyCode.Backspace:
						_spliceText(_startHighlightChar, _endHighlightChar);
					case KeyCode.Delete:
						_spliceText(_startHighlightChar, _endHighlightChar);
					case KeyCode.A if (control): // Select all
						_startHighlightChar = 0;
						_endHighlightChar = text.length;
					case _:
						// Any other things to track?
						//trace(k);
				}
			}
		} else {
			if(_cursorPos >= 0 && _cursorPos <= text.length) {
				// Check for other single keys
				for(k in keysDown) {
					switch(k) {
						case KeyCode.Left if (control && shift): // Ctrl + shift + left
							_startHighlightChar = _cursorPos;
							var _newPos = _cursorPos-2;
							while(_newPos>=0 && Text.wordWrapCharacters.indexOf(charCodes[_newPos]) == -1) _newPos--;
							if(_newPos<0) _newPos = 0;
								else _newPos++;
							_cursorPos = _newPos;
							_endHighlightChar = _cursorPos;
							_cursorBlinkState = true;
						case KeyCode.Right if (control && shift): // Ctrl + shift + right
							_startHighlightChar = _cursorPos;
							var _newPos = _cursorPos+1;
							while(_newPos<=charCodes.length && Text.wordWrapCharacters.indexOf(charCodes[_newPos]) == -1) _newPos++;
							if(_newPos>charCodes.length) _newPos = charCodes.length;
							_cursorPos = _newPos;
							_endHighlightChar = _cursorPos;
							_cursorBlinkState = true;
						case KeyCode.Left if (shift): // Shift + left
							if(_startHighlightChar == -1 ) _startHighlightChar = _cursorPos;
							if(_cursorPos>0) _cursorPos--;
							_endHighlightChar = _cursorPos;
							_cursorBlinkState = true;
						case KeyCode.Left if (control): // Ctrl + left
							var _newPos = _cursorPos-2;
							while(_newPos>=0 && Text.wordWrapCharacters.indexOf(charCodes[_newPos]) == -1) _newPos--;
							if(_newPos<0) _newPos = 0;
								else _newPos++;
							_cursorPos = _newPos;
							_cursorBlinkState = true;
						case KeyCode.Right if (shift): // Shift + right
							if(_startHighlightChar == -1 ) _startHighlightChar = _cursorPos;
							if(_cursorPos<text.length) _cursorPos++;
							_endHighlightChar = _cursorPos;
							_cursorBlinkState = true;
						case KeyCode.Right if (control): // Ctrl + right
							var _newPos = _cursorPos+1;
							while(_newPos<=charCodes.length && Text.wordWrapCharacters.indexOf(charCodes[_newPos]) == -1) _newPos++;
							if(_newPos>charCodes.length) _newPos = charCodes.length;
							_cursorPos = _newPos;
							_cursorBlinkState = true;
						case KeyCode.Left:
							if(_cursorPos>0) _cursorPos--;
							_cursorBlinkState = true;
						case KeyCode.Right:
							if(_cursorPos<text.length) _cursorPos++;
							_cursorBlinkState = true;
						case KeyCode.Backspace:
							_spliceText(_cursorPos-1, _cursorPos);
						case KeyCode.Delete:
							_spliceText(_cursorPos, _cursorPos+1);
						case KeyCode.A if (control): // Select all
							_startHighlightChar = 0;
							_endHighlightChar = text.length;
						case _:
							// Any other things to track?
							//trace(k);
					}
				}
			}
		}
	}

	private function _spliceText(start:Int, end:Int):String {
		var s = start;
		var e = end;
		if(e<s) {
			s = end;
			e = start;
		}
		if(s>=0 && e<=text.length) {
			var s1 = text.substr(0, s);
			var s2 = text.substr(e);
			var s3 = text.substring(s, e);
			text = s1 + s2;

			if(_cursorPos>s)
				_cursorPos-=s3.length; // Move the cursor to position to follow removed text

			if(_cursorPos<0) _cursorPos = 0;
			if(_cursorPos>text.length) _cursorPos = text.length;

			// Clear highlight
			clearHighlight();

			return s3;
		}

		return null;
	}

	override private function cutListener():String {
		// Remove and return the text
		var cutText:String = null;
		
		if(highlighted) {
			cutText = _spliceText(_startHighlightChar, _endHighlightChar);
		}

		// Send back the currently selected text
		return cutText;
	}

	override private function copyListener():String {
		var copyText:String = null;
		// Get the currently highlighted text
		if(highlighted) {
			var s = _startHighlightChar;
			var e = _endHighlightChar;
			if(_endHighlightChar<s) {
				s = _endHighlightChar;
				e = _startHighlightChar;
			}
			if(highlighted) {
				copyText = text.substring(_startHighlightChar, _endHighlightChar);
			}
		}
		// Send back the currently selected text
		return copyText;
	}

	override private function pasteListener(paste:String) {
		if(highlighted) {
			_spliceText(_startHighlightChar, _endHighlightChar);
		}

		// Insert new text
		var s1 = text.substr(0, _cursorPos);
		var s2 = text.substr(_cursorPos);

		text = s1 + paste + s2;
	}

	public var highlighted(get,never):Bool;

	private function get_highlighted() {
		return (_startHighlightChar != _endHighlightChar && _startHighlightChar >= 0 && _endHighlightChar >= 0 && _startHighlightChar <= charCodes.length && _endHighlightChar <= charCodes.length);
	}

	public function clearHighlight() {
		_startHighlightChar = -1;
		_endHighlightChar = -1;
	}
	public function setTextFieldRule(newRule:TextFieldRule) {
		//TODO: enable or disable editable capabilities based on rule
		// Notify parent of the change
		layoutIsValid = false;
	}
	override public function render(g2: Graphics): Void {
		super.render(g2);
		// Check if highlight is happening
		if(highlighted) {
			var s = _startHighlightChar;
			var e = _endHighlightChar;
			if(_endHighlightChar<s) {
				s = _endHighlightChar;
				e = _startHighlightChar;
			}
			if(highlighted) {
				g2.color = kha.Color.fromFloats(0,0,0,.4);
				
				if(!fontSettings.wordWrap) { // Single line, draw it quickly
					var sR = characterRects[s];
					var eR:Rect;
					eR = characterRects[e-1];
					g2.fillRect(sR.position.x, sR.position.y, eR.position.x + eR.size.w - sR.position.x, eR.position.y + eR.size.h - sR.position.y);
				} else { // Possibly multi-line, iterate
					for(i in s ... e) {
						var r = characterRects[i];
						g2.fillRect(r.position.x, r.position.y, r.size.w, r.size.h);
					}
				}
			}
		}

		// Check if cursor is blinking
		if(_cursorBlinkState && _cursorPos>=0 && _cursorPos<characterRects.length) {
			var cR = characterRects[_cursorPos];
			g2.color = kha.Color.Black;
			g2.fillRect(cR.position.x-1, cR.position.y, 2, cR.size.h);
		}
	}

}
enum TextFieldRule {
	// Font
	editable(mode:EditableRule);

}
enum EditableRule{
	SelectableAndEditable;
	SelectableNotEditable;
	NotSelectableOrEditable;
}
