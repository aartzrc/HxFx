package hxfx.widget;

import hxfx.core.NodeBase;
import kha.Assets;
import tests.ComponentWindow;

@:bindable
class TextField extends Text {
	
	@:bindable
	var _startHighlightChar:Int = -1;
	@:bindable
	var _endHighlightChar:Int = -1;
	@:bindable
	var _focused:Bool = true;

	public function new() {
		super();

		mouseSubscribe = true;
		
		// Bind to mouse
		Bind.bind(this.mouseData.b1down, _mouseb1Down);
		Bind.bindAll(this.mouseData, _mouseChanged);

		// Bind/react to highlight changes
		Bind.bind(this._startHighlightChar, _highlightChanged);
		Bind.bind(this._endHighlightChar, _highlightChanged);
	}

	private function _highlightChanged(from:Int, to:Int) {
		layoutIsValid = false;
	}

	var dragStart:Position;
	var dragCurrent:Position;
	private function _mouseb1Down(from:Bool, to:Bool) {
		if(to && mouseData.mouseInBounds) {
			// Button down and inside bounds, start tracking drag
			if(dragStart == null) {
				dragStart = new Position({x: this.mouseData.x, y: this.mouseData.y });
			}
		} else if(to) { // Clicked out of bounds, clear highlight
			_startHighlightChar = -1;
			_endHighlightChar = -1;
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

			trace(dragCurrent);
			
			// Calculate characters selected
			for(i in 0 ... characterRects.length) {
				if(characterRects[i].inBounds(dragStart)) {
					_startHighlightChar = i;
				}
				if(characterRects[i].inBounds(dragCurrent)) {
					_endHighlightChar = i;
				}
			}
		}

		//trace(_startHighlightChar + " : " + _endHighlightChar);
	}

	override public function render(g2: Graphics): Void {
		super.render(g2);

		// Check if highlight is happening
		if(_startHighlightChar >= 0 && _endHighlightChar >= 0 && _startHighlightChar < characterRects.length && _endHighlightChar < characterRects.length) {
			g2.color = kha.Color.fromFloats(0,0,0,.4);
			var s = _startHighlightChar;
			var e = _endHighlightChar;
			if(_endHighlightChar<s) {
				s = _endHighlightChar;
				e = _startHighlightChar;
			}
			trace("chars: " + s + " : " + e);
			var sR = characterRects[s];
			var eR = characterRects[e];

			trace(sR);
			trace(eR);
			g2.fillRect(sR.position.x, sR.position.y, eR.position.x + eR.size.w - sR.position.x, eR.position.y + eR.size.h - sR.position.y);
		}
	}

}