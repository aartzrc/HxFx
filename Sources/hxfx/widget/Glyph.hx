package hxfx.widget;

import hxfx.core.NodeBase;
import kha.Assets;
import tests.ComponentWindow;

/** 
A single character or symbol
Uses 'standard' 12pt, 16px, 1em, 100% size concept at 96dpi - for example: https://websemantics.uk/articles/font-size-conversion/
All font sizes are based on this, font size is float - 1.0 == 1em size
**/
class Glyph extends NodeBase {
	@:bindable
	public var glyph:String = "";
	@:bindable
	public var font:Font;
	@:bindable
	public var fontSize:Float = 1;

	var _fontScaledSize:Float = 1;
	var _fontIntSize:Int = 16;

	public function new() {
		super();
		Bind.bind(this.glyph, _recalcSize);
		Bind.bind(this.font, _recalcSize);
		Bind.bind(this.scale, _recalcSize);
		Bind.bind(this.fontSize, _recalcSize);

		// Test mouse - add to textfield later
		mouseSubscribe = true;
		bindx.Bind.bindAll(this.mouseData, mouseMoved);
	}

	function mouseMoved(origin:IBindable,name:String, from:Dynamic, to:Dynamic) {
		//trace(this.mouseData);
		//trace(this.mouseData.x);
	}

	public function _recalcSize(from:Dynamic, to:Dynamic) {
		_fontScaledSize = fontSize * scale;
		_fontIntSize = Math.round(16*_fontScaledSize);
		var pSize = this.size;
		this.size = get_size();
		Bind.notify(this.size, pSize, this.size);
	}
	
	function get_size() {
		if(font == null) {
			// Guess dimensions
			return new Size({ w: 11.5*_fontScaledSize, h: 16*_fontScaledSize });
		} else {
			var h = font.height(_fontIntSize);
			var w = font.width(_fontIntSize, glyph);
			return new Size({ w: w, h: h });
		}
	}

	override public function render(g2: Graphics): Void {
		super.render(g2);

		if(font != null) {
			g2.font = font;
			g2.fontSize = _fontIntSize;
			g2.color = Color.Red;
			g2.drawString(glyph, 0, 0);

			g2.color = Color.fromFloats(0,0,0,.15);
		}
	}
}