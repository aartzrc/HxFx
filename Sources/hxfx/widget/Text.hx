package hxfx.widget;

import hxfx.core.NodeBase;
import kha.Assets;
import tests.ComponentWindow;

@:bindable
class Text extends NodeBase {
	public var text:String = "";

	public function new() {
		super();
		Bind.bind(this.text, doTextChange);
	}

	public function doTextChange(from:String, to:String) {
		var thisRect:Rect = new Rect({ position: { x: 0, y: 0 }, size: { w: layoutSize.w, h: layoutSize.h } });
		addRedrawRect(thisRect);
		redrawRequested = false; // Had to toggle redraw to make it propagate - need to review render requests
		redrawRequested = true;
		//redrawRects([thisRect]);
	}

	override private function _calcSize(size:Size) {
		// Determine what size I want to be based on text size
		// Ignore most layout rules, the parent container will handle positioning
		var useFont = font;
		var useFontSize = fontSize;

		if(useFont != null) {
			size.h = font.height(useFontSize);
			size.w = font.width(useFontSize, text);
		} else {
			// No font? fake some size
			size.h = useFontSize;
			size.w = (11.5*(useFontSize/16)) * text.length;
		}

		return size;
	}

	public var characterRects(get,never):Array<Rect>;

	var font(get,never):Font;

	function get_font() {
		var useFont:Font = null;
		for(r in layoutRules) {
			switch(r) {
				case LayoutRule.Font(f):
					useFont = f;
				case _:
					// Ignore other rules
			}

			if(useFont != null) return useFont;
		}

		return useFont;
	}

	var fontSize(get, never):Int;

	function get_fontSize() {
		// TODO: calculate font size using scale/dpi settings - etc etc
		var fontSize:Float = 16;
		for(r in layoutRules) {
			switch(r) {
				case LayoutRule.FontSize(v):
					fontSize = v;
				case _:
					// Ignore other rules
			}
		}

		return Math.round(fontSize);
	}

	var color(get, never):kha.Color;

	function get_color() {
		var color = kha.Color.Transparent;
		for(r in layoutRules) {
			switch(r) {
				case LayoutRule.Color(c):
					color = c;
				case _:
					// Ignore other rules
			}
		}

		return color;
	}
	
	function get_characterRects() {
		var charRects = new Array<Rect>();
		// Try to get the font
		var useFont = font;
		var useFontSize = fontSize;

		if(useFont != null) {
			var x:Float = 0;
			var h = font.height(useFontSize);
			for(i in 1 ... text.length+1) {
				var w = font.width(useFontSize, text.substr(0, i));
				
				charRects.push(new Rect({position: {x: x, y: 0}, size: {w:w-x, h:h}}));
				x = w;
			}
		} else {
			var x:Float = 0;
			for(i in 0 ... text.length) {
				// Fake the sizes to provide some initial feedback to layout engine
				var w = 11.5*(useFontSize/16);
				charRects.push(new Rect({position: {x: x, y: 0}, size: { w: w, h: 16*(useFontSize/16) }}));
				x+=w;
			}
		}

		return charRects;
	}

	override public function render(g2: Graphics): Void {
		super.render(g2);

		var useFont = font;

		if(useFont != null) {
			g2.font = useFont;
			g2.fontSize = fontSize;
			g2.color = color;
			g2.drawString(text, 0, 0);

			// Draw character rectangles - debug
			g2.color = kha.Color.fromFloats(0,0,0,.15);
			for(r in characterRects) {
				g2.drawRect(r.position.x, r.position.y, r.size.w, r.size.h, 1);
			}
		}
	}
}