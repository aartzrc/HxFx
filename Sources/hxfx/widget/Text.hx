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

	public function new() {
		super(new FontSettings());
		fontGlyphs = new Array<Int>();
		addFontGlyphs = new Array<Int>();
		Bind.bind(this.text, doTextChange);
	}

	public var fontSettings(get,never):FontSettings;

	public function get_fontSettings() {
		return cast settings;
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
		var useFont = textNode.fontSettings.font;
		var useFontSize = Math.round(textNode.fontSettings.fontSize);

		if(useFont != null) {
			size.h = useFont.height(useFontSize);
			size.w = useFont.width(useFontSize, textNode.text);
		} else {
			// No font? fake some size
			size.h = useFontSize;
			size.w = (11.5*(useFontSize/16)) * textNode.text.length;
		}

		return size;
	}

	public var characterRects(get,never):Array<Rect>;
	
	var charRects:Array<Rect> = new Array<Rect>();
	function get_characterRects() {
		// Check for cache
		if(charRects.length>0) return charRects;
		
		var useFont = fontSettings.font;
		var useFontSize = Math.round(fontSettings.fontSize);
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

		var useFont = fontSettings.font;

		if(useFont != null) {
			g2.font = useFont;
			g2.fontSize = Math.round(fontSettings.fontSize);
			if(addFontGlyphs.length > 0) {
				for(i in addFontGlyphs) { // Check for extra font glyphs that are not in the current set
					if(g2.fontGlyphs.indexOf(i) == -1)
						g2.fontGlyphs.push(i);
				}
				fontGlyphs = g2.fontGlyphs; // Save the update
				addFontGlyphs = new Array<Int>(); // Clear the additions
			}
			
			g2.color = settings.color;
			g2.drawString(text, 0, 0);

			// Draw character rectangles - debug
			/*g2.color = kha.Color.fromFloats(0,0,0,.15);
			for(r in characterRects) {
				g2.drawRect(r.position.x, r.position.y, r.size.w, r.size.h, 1);
			}*/
		}
	}
}

@:bindable
class FontSettings extends NodeBaseSettings implements IBindable {
	public var font:kha.Font;
	public var fontSize:Float;
}