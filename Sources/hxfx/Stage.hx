package hxfx;

import hxfx.core.NodeBase;
import hxfx.layout.AbsoluteContainer;
import hxfx.core.data.Mouse;
import hxfx.core.data.Keyboard;
import kha.input.KeyCode;

/**
Each Window has a Stage, this is the root level display canvas that fills the view area
The Stage receives invalid rectangle information from it's children and requests a redraw as needed
**/
//@:bindable
class Stage extends NodeBase {
	
	var _redrawRects = new Array<Rect>();
	var window:Window;
	var currentFocus:NodeBase;

	public function new(window:Window) {
		this.window = window;
		
		super();
		
		Bind.bindAll(window.windowSize, doWindowSizeChange);
		Bind.bind(window.mouse, attachMouse);
		Bind.bind(window.keyboard, attachKeyboard);
		Bind.bind(this.layoutIsValid, _layoutIsValid_Changed);
	}

	private function attachMouse(from:Mouse, to:Mouse) {
		this.mouseData = this.window.mouse.mouseData;
		Bind.bindAll(mouseData, _doMouseChanged);
	}

	override private function _doMouseChanged(origin:IBindable, name:String, from:Dynamic, to:Dynamic) {
		super._doMouseChanged(origin, name, from, to);

		// Stage handles in bounds - only a single node stack should be in bounds at a time
		if(!_checkMouseInBounds()) { // Nothing found, clear all inbounds flags
			_clearMouseInBounds();
		}
	}

	private function attachKeyboard(from:Keyboard, to:Keyboard) {
		Bind.bind(to.keysDown, _keysDownListener);
		Bind.bind(to.keyPress, _keyPressListener);
		to.cutCallback = this.cutListener;
		to.copyCallback = this.copyListener;
		to.pasteCallback = this.pasteListener;
	}

	private function _keysDownListener(from:List<KeyCode>, to:List<KeyCode>) {
		_keysDownChange(window.keyboard.keysDown);
	}

	private function _keyPressListener(from:String, to:String) {
		_keyPressed(to);
	}

	private function doWindowSizeChange(origin:IBindable, name: String, from:Dynamic, to:Dynamic) {
		layoutIsValid = false;
	}

	private function _layoutIsValid_Changed(from:Bool, to:Bool) {
		if(!to) {
			// Stage has become invalid, force layout cycle
			layoutToSize(new Size({ w: window.windowSize.w, h: window.windowSize.h }), true);

			// TODO: push invalid rect to render engine, currently whole stage get re-drawn

			// Layout up to date, time to render
			System.renderNextFrame = true;
		}
	}

	/*
	override public function redrawRects(rectArray:Array<Rect>) {
		_redrawRects.concat(rectArray);

		// TODO: Stage should handle which nodes get render calls and also combine invalid rects to optimize update

		// Possibly bind invalidRects at Window level to renderNextFrame?
		System.renderNextFrame = true;
	}
	*/

	/*override private function _childPropertyChanged(origin:IBindable, name:String, from:Dynamic, to:Dynamic) {
		super._childPropertyChanged(origin, name, from, to);
		if(name == "redrawRequested") {
			var child = cast(origin, NodeBase);
			// redrawRequested change
			if(to == true) {
				// NodeBase has merged redraw rects for us, we just need to tell the render engine to do its thing
				System.renderNextFrame = true;
			}
		}
	}*/
	
	override public function setCursor(cursorName:String) {
		// Tell Window to change the cursor
		window.setCursor(cursorName);
	}
}