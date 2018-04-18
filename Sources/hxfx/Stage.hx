package hxfx;

import hxfx.core.NodeBase;
import hxfx.core.data.Mouse;

/**
Each Window has a Stage, this is the root level display canvas that fills the view area
The Stage receives invalid rectangle information from it's children and requests a redraw as needed
**/
//@:bindable
class Stage extends NodeBase {
	
	var _redrawRects = new Array<Rect>();
	var window:Window;

	public function new(window:Window) {
		this.window = window;
		
		super();
		
		Bind.bindAll(window.windowSize, doWindowSizeChange);
		Bind.bind(window.mouse, attachMouse);
	}

	private function attachMouse(from:Mouse, to:Mouse) {
		this.mouseData = this.window.mouse.mouseData;
		Bind.bindAll(mouseData, _doMouseChanged);
	}

	private function doWindowSizeChange(origin:IBindable, name: String, from:Dynamic, to:Dynamic) {
		layoutToSize(new Size({ w: window.windowSize.w, h: window.windowSize.h }));
	}

	/*
	override public function redrawRects(rectArray:Array<Rect>) {
		_redrawRects.concat(rectArray);

		// TODO: Stage should handle which nodes get render calls and also combine invalid rects to optimize update

		// Possibly bind invalidRects at Window level to renderNextFrame?
		System.renderNextFrame = true;
	}
	*/

	override private function _childPropertyChanged(origin:IBindable, name:String, from:Dynamic, to:Dynamic) {
		super._childPropertyChanged(origin, name, from, to);
		if(name == "redrawRequested") {
			var child = cast(origin, NodeBase);
			// redrawRequested change
			if(to == true) {
				// NodeBase has merged redraw rects for us, we just need to tell the render engine to do its thing
				System.renderNextFrame = true;
			}
		}
	}
	
	override public function setCursor(cursorName:String) {
		// Tell Window to change the cursor
		window.setCursor(cursorName);
	}
}