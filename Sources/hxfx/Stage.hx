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

	private function doWindowSizeChange(name: String, from:Dynamic, to:Dynamic) {
		this.size = new Size({ width: window.windowSize.width, height: window.windowSize.height });
	}

	override public function redrawRects(rectArray:Array<Rect>) {
		_redrawRects.concat(rectArray);

		// TODO: Stage should handle which nodes get render calls and also combine invalid rects to optimize update

		// Possibly bind invalidRects at Window level to renderNextFrame?
		System.renderNextFrame = true;
	}

	override public function render(g2:Graphics) {
		super.render(g2);

		// Clear the old array, any better way to manage this?
		_redrawRects = new Array<Rect>();
	}
}