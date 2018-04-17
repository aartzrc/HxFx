package hxfx.widget;

import hxfx.core.NodeBase;
import kha.Assets;
import tests.ComponentWindow;

@:bindable
class Text extends NodeBase {
	public var text:String = "";
	var font:Font;

	public function new() {
		super();
		Bind.bind(this.text, doTextChange);

		// Test mouse - add to textfield later
		mouseSubscribe = true;
		bindx.Bind.bindAll(this.mouseData, mouseMoved);
	}

	function mouseMoved(origin:IBindable,name:String, from:Dynamic, to:Dynamic) {
		//trace(this.mouseData);
		//trace(this.mouseData.x);
	}

	public function doTextChange(from:String, to:String) {
		//var thisRect:Rect = new Rect({ position: { x: relativePosition.x, y: relativePosition.y }, size: { w: this.size.w, h: this.size.h } });
		//redrawRects([thisRect]);
	}

	public var characterRects(get,never):Array<Rect>;
	
	function get_characterRects() {
		var charRects = new Array<Rect>();
		if(font == null) {
			/*if(Assets.fonts.ARIALUNI != null)
				font = Assets.fonts.ARIALUNI;*/
			if(Assets.fonts.arial != null)
				font = Assets.fonts.arial;
		}

		if(font != null) {
			var x:Float = 0;
			var h = font.height(24);
			for(i in 1 ... text.length+1) {
				var w = font.width(24, text.substr(0, i));
				
				charRects.push(new Rect({position: {x: 0, y: 0}, size: {w:w-x, h:h}}));
				x = w;
			}
		} else {
			// Fake the sizes to provide some initial feedback to layout engine?
		}

		return charRects;
	}

	override public function render(g2: Graphics): Void {
		super.render(g2);

		//g2.drawString(text, 10, 10);

		if(ComponentWindow.arial != null) {
			g2.font = ComponentWindow.arial;
			g2.fontSize = 24;
			g2.color = Color.Red;
			g2.drawString(text, 0, 0);

			g2.color = Color.fromFloats(0,0,0,.15);

			for(r in characterRects) {
				g2.drawRect(r.position.x, r.position.y, r.size.w, r.size.h, 1);
			}

			trace(characterRects);
		}
	}
}