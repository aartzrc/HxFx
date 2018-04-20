package hxfx.widget;

import hxfx.core.NodeBase;
import kha.Assets;
import kha.Scheduler;
import kha.input.KeyCode;
import tests.ComponentWindow;

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

		mouseSubscribe = true;
		
		// Bind to mouse
		Bind.bind(this.mouseData.b1down, _mouseb1Down);
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

	
	private function _mouseChanged(origin:IBindable, name:String, from:Dynamic, to:Dynamic) {
		if(mouseData.b1down && dragStart != null) { // Button down and we have a start drag location, monitor and calculate highlighting
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
				var inBoundsRelativeStart = characterRects[i].inBoundsRelative(dragStart);
				var inBoundsRelativeCurrent = characterRects[i].inBoundsRelative(dragCurrent);
				if(inBoundsRelativeStart.x>0 && inBoundsRelativeStart.x<=.5) {
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
		// Update text
		if(_cursorPos >= 0 && _cursorPos <= text.length) {
			var s1 = text.substr(0, _cursorPos);
			var s2 = text.substr(_cursorPos);
			text = s1 + k + s2;
			_cursorPos+=k.length;
		}
	}

	override private function _keysDownChange(keysDown:List<KeyCode>) {
		// Capture keys
		//trace(keysDown);
		var render = false;
		if(_cursorPos >= 0 && _cursorPos <= text.length) {
			for(k in keysDown) {
				switch(k) {
					case KeyCode.Left:
						if(_cursorPos>0) _cursorPos--;
						_cursorBlinkState = true;
						render = false;
					case KeyCode.Right:
						if(_cursorPos<text.length) _cursorPos++;
						_cursorBlinkState = true;
						render = true;
					case KeyCode.Backspace:
						if(_cursorPos>0) {
							var s1 = text.substr(0, _cursorPos-1);
							var s2 = text.substr(_cursorPos);
							text = s1 + s2;
							_cursorPos--;
						}
					case KeyCode.Delete:
						if(_cursorPos<text.length) {
							var s1 = text.substr(0, _cursorPos);
							var s2 = text.substr(_cursorPos+1);
							text = s1 + s2;
						}
					case _:
						// Any other things to track?
						trace(k);
				}
			}
		}
	}

	override public function render(g2: Graphics): Void {
		super.render(g2);

		// Check if highlight is happening
		if(_startHighlightChar != _endHighlightChar) {
			var s = _startHighlightChar;
			var e = _endHighlightChar;
			if(_endHighlightChar<s) {
				s = _endHighlightChar;
				e = _startHighlightChar;
			}
			if(_startHighlightChar >= 0 && _endHighlightChar >= 0 && _startHighlightChar < characterRects.length && _endHighlightChar < characterRects.length) {
				g2.color = kha.Color.fromFloats(0,0,0,.4);
				
				var sR = characterRects[s];
				var eR:Rect;
				/*if(_endHighlightChar < characterRects.length) { // Check for edge case of highlighting past last character
					eR = characterRects[e];
					g2.fillRect(sR.position.x, sR.position.y, eR.position.x - sR.position.x, eR.position.y + eR.size.h - sR.position.y);
				} else {*/
					eR = characterRects[e-1];
					g2.fillRect(sR.position.x, sR.position.y, eR.position.x + eR.size.w - sR.position.x, eR.position.y + eR.size.h - sR.position.y);
				//}
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