package hxfx.widget;

import hxfx.core.NodeBase;

@:bindable
class Text extends NodeBase {
	public var text:String = "";
	var charCodes:Array<Int>;

	// Font glyph caching/updating for UTF-8 characters - NOT FULLY/PROPERLY IMPLEMENTED
	// this should probably be at the Window level and managed by a lazy load font system
	public static var fontGlyphs:Array<Int>; // The Kha graphics font glyphs
	public static var addFontGlyphs:Array<Int>; // Glyphs to add during next render

	public var fontRules(default,null):List<FontRule>;

	public function new() {
		super();
		fontRules = new List<FontRule>();
		fontGlyphs = new Array<Int>();
		addFontGlyphs = new Array<Int>();
		Bind.bind(this.text, doTextChange);
	}

	public function doTextChange(from:String, to:String) {
		charCodes = new Array<Int>();
		for(i in 0 ... to.length) { // Save the text as char codes - used by font manager
			var charCode = to.charCodeAt(i);
			charCodes.push(charCode);
			if(fontGlyphs.indexOf(charCode) == -1)
				addFontGlyphs.push(charCode);
		}
		//trace(fontGlyphs.length);

		charRects = new Array<Rect>(); // Clear cache
		layoutIsValid = false; // I changed, notify my parent
	}

	private override function _calcSize(layoutSize:Size) {
		return calcSize(this, layoutSize);
	}

	public static override function calcSize(textNode:Text, size:Size) {
		// Determine what size I want to be based on text size
		// Ignore most layout rules, the parent container will handle positioning
		var useFont = textNode.font;
		var useFontSize = textNode.fontSize;

		if(useFont != null) {
			size.h = textNode.font.height(useFontSize);
			size.w = textNode.font.width(useFontSize, textNode.text);
		} else {
			// No font? fake some size
			size.h = useFontSize;
			size.w = (11.5*(useFontSize/16)) * textNode.text.length;
		}

		return size;
	}

	public var characterRects(get,never):Array<Rect>;

	var font(get,never):Font;

	function get_font() {
		var useFont:Font = null;
		for(r in fontRules) {
			switch(r) {
				case FontRule.Font(f):
					useFont = f;
				case _:
					// Ignore other rules
			}

			if(useFont != null) break;
		}

		return useFont;
	}

	var fontSize(get, never):Int;

	function get_fontSize() {
		// TODO: calculate font size using scale/dpi settings - etc etc
		var fontSize:Float = 16;
		for(r in fontRules) {
			switch(r) {
				case FontRule.FontSize(v):
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
				case BaseRule.Color(c):
					color = c;
				case _:
					// Ignore other rules
			}
		}

		return color;
	}

	public function setFontRule(newRule:FontRule) {
		var ruleConstructor = Type.enumConstructor(newRule);
		trace(ruleConstructor);
		// TODO: check for other rules that should be removed during this update
		switch(ruleConstructor) {
			case "Font":
				for(r in fontRules) {
					if(Type.enumConstructor(r) == ruleConstructor) {
						fontRules.remove(r);
					}
				}
		}

		// Clear cache if font changes
		switch(newRule) {
			case FontRule.Font(_), FontRule.FontSize(_):
				charRects = new Array<Rect>();
			case _:
				// Ignore
		}

		fontRules.add(newRule);

		// Notify parent of the change
		layoutIsValid = false;
	}
	
	var charRects:Array<Rect> = new Array<Rect>();
	function get_characterRects() {
		// Check for cache
		if(charRects.length>0) return charRects;
		
		// Try to get the font
		var useFont = font;
		var useFontSize = fontSize;
		var x:Float = 0;

		if(useFont != null) {
			var h = useFont.height(useFontSize);
			//var ki = useFont._get(useFontSize, charCodes); // Make Kha draw the whole string, this is a workaround to make sure unicode character sizes are fully calculated
			for(i in 1 ... charCodes.length+1) {
				var w = useFont.widthOfCharacters(useFontSize, charCodes, 0, i);				
				charRects.push(new Rect({position: {x: x, y: 0}, size: {w:w-x, h:h}}));
				x = w;
			}
			//trace(charRects);
		} else {
			for(i in 0 ... text.length) {
				// Fake the sizes to provide some initial feedback to layout engine
				var w = 11.5*(useFontSize/16);
				charRects.push(new Rect({position: {x: x, y: 0}, size: { w: w, h: 16*(useFontSize/16) }}));
				x+=w;
			}
		}

		// Push an extra rect for the end of the text
			charRects.push(new Rect({position: {x: x, y: 0}, size: { w: 0, h: 16*(useFontSize/16) }}));

		return charRects;
	}

	override public function render(g2: Graphics): Void {
		super.render(g2);

		var useFont = font;

		if(useFont != null) {
			g2.font = useFont;
			g2.fontSize = fontSize;
			if(addFontGlyphs.length > 0) {
				for(i in addFontGlyphs) { // Check for extra font glyphs that are not in the current set
					if(g2.fontGlyphs.indexOf(i) == -1)
						g2.fontGlyphs.push(i);
				}
				fontGlyphs = g2.fontGlyphs; // Save the update
				addFontGlyphs = new Array<Int>(); // Clear the additions
			}
			
			g2.color = color;
			g2.drawString(text, 0, 0);

			// Draw character rectangles - debug
			/*g2.color = kha.Color.fromFloats(0,0,0,.15);
			for(r in characterRects) {
				g2.drawRect(r.position.x, r.position.y, r.size.w, r.size.h, 1);
			}*/
		}
	}
}

enum FontRule {
	// Font
	Font(f:kha.Font);
	FontSize(s:Float);
}