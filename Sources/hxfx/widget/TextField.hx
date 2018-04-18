package hxfx.widget;

import hxfx.core.NodeBase;
import kha.Assets;
import tests.ComponentWindow;

@:bindable
class TextField extends Text {
	
	public function new() {
		super();

		mouseSubscribe = true;
		// Watch for mouse in bounds
		bindx.Bind.bind(this.mouseData.mouseInBounds, _mouseInBounds);
	}

	// The binds below cascade bind/unbind to monitor the mouse click/drag cycle
	
	// TODO: while mouse is down, always track it - code below unbinds when out of bounds which isn't quite right

	var mouseInBoundsUnbind:Dynamic = null;
	private function _mouseInBounds(from:Bool, to:Bool) {
		if(to) {
			//mouseInBoundsUnbind = bindx.Bind.bind(this.mouseData.b1down, _mouseb1Down);
			bindx.Bind.bind(this.mouseData.b1down, _mouseb1Down); // bindx is not returning a callback during compile, need to review
		} else {
			//if(mouseInBoundsUnbind != null) mouseInBoundsUnbind();
			bindx.Bind.unbind(this.mouseData.b1down, _mouseb1Down);
			if(mouseDraggingUnbind != null) mouseDraggingUnbind();
		}
	}

	var mouseDraggingUnbind:Dynamic;
	private function _mouseb1Down(from:Bool, to:Bool) {
		if(to) {
			mouseDraggingUnbind = bindx.Bind.bindAll(this.mouseData, _mouseDragging);
		} else {
			if(mouseDraggingUnbind != null) mouseDraggingUnbind();
		}
	}

	var dragStart:Position;
	private function _mouseDragging(origin:IBindable, name:String, from:Dynamic, to:Dynamic) {
		if(dragStart == null) {
			dragStart = new Position({x: this.mouseData.x, y: this.mouseData.y });
		}
		trace(dragStart.x + " : " + dragStart.y + " to " + this.mouseData.x + " : " + this.mouseData.y);
	}

}