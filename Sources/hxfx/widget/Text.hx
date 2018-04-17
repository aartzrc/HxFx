package hxfx.widget;

import hxfx.core.NodeBase;

@:bindable
class Text extends NodeBase {
	public var text:String = "";

	public function new() {
		super();
		Bind.bind(this.text, doTextChange);
	}

	public function doTextChange(from:String, to:String) {
		var thisRect:Rect = new Rect({ position: { left: relativePosition.left, top: relativePosition.top }, size: { width: this.size.width, height: this.size.height } });
		redrawRects([thisRect]);
	}

	override public function render(g2: Graphics): Void {
		super.render(g2);

		trace(text);
	}
}