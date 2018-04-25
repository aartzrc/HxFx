package hxfx.widget;

import hxfx.core.NodeBase;

using StringTools;

@:bindable
class Text extends NodeBase {
	public static var wordWrapCharacters:Array<Int> = [32, 189]; // Space, dash

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
		_wrapIndexes = null; // Clear cache
		layoutIsValid = false; // I changed, notify my parent
	}

	private override function _calcSize(layoutSize:Size) {
		return calcSize(this, layoutSize);
	}

	public static override function calcSize(textNode:Text, size:Size) {
		// Determine what size I want to be based on text size
		// Ignore most layout rules, the parent container will handle positioning
		if(!textNode.fontSettings.wordWrap) {
			return stringSize(textNode, textNode.text);
		} else {
			var wrapStrings = wrapStrings(textNode, size);
			var newSize = new Size({w:0, h:textNode.fontSettings.fontSize*wrapStrings.length});
			// Get wrap chunks, find max width
			for(c in wrapStrings) {
				var chunkSize = stringSize(textNode, c);
				if(chunkSize.w > newSize.w) newSize.w = chunkSize.w;
			}

			return newSize;
		}
	}

	private static function stringSize(textNode:Text, text:String) {
		var stringSize:Size = new Size({w:0, h:0});
		if(textNode.fontSettings.font != null) {
			stringSize.h = textNode.fontSettings.font.height(Math.round(textNode.fontSettings.fontSize));
			stringSize.w = textNode.fontSettings.font.width(Math.round(textNode.fontSettings.fontSize), text);
		} else {
			// No font? fake some size
			stringSize.h = textNode.fontSettings.fontSize;
			stringSize.w = (11.5*(textNode.fontSettings.fontSize/16)) * text.length;
		}
		return stringSize;
	}

	public static function wrapStrings(textNode:Text, size:Size) {
		var wrapStrings = new Array<String>();

		// Loop over text chunks - wrap when we hit an edge
		var lastWrapPos = 0;
		var lastString = "";
		for(i in textNode.wrapIndexes) {
			var tryString = textNode.text.substring(lastWrapPos, i.end);
			var trySize = stringSize(textNode, tryString);
			if(trySize.w > size.w) {
				// Text has exceeded width, time to wrap!
				// Store the string
				wrapStrings.push(lastString.rtrim());
				// Update the position
				lastWrapPos = i.begin;
				// Reset the string
				lastString = "";
			} else {
				lastString = tryString;
			}
		}

		// Store the last chunk
		wrapStrings.push(textNode.text.substr(lastWrapPos));

		return wrapStrings;
	}

	public var wrapIndexes(get, never):Array<WrapChunk>;

	var _wrapIndexes:Array<WrapChunk>;
	function get_wrapIndexes() {
		// Check cache
		if(_wrapIndexes != null) return _wrapIndexes;

		// Build the chunks
		// TODO: this is heavy, is there a split routine that would work better?
		_wrapIndexes = new Array<WrapChunk>();
		var curString:String = "";
		var lastPos = 0;
		for(i in 0 ... text.length) {
			curString+=text.charAt(i);
			if(wordWrapCharacters.indexOf(text.charCodeAt(i)) != -1) {
				// Found a wrap location, save it
				var t = curString.length;
				curString = curString.trim(); // Ignore spaces
				if(curString.length>0) {
					_wrapIndexes.push({begin:lastPos, end:lastPos+curString.length});
				}
				lastPos+=t;
				curString = "";
			}
		}

		// Grab the last chunk
		curString = curString.trim(); // Ignore spaces
		if(curString.length>0) {
			_wrapIndexes.push({begin:lastPos, end:lastPos+curString.length});
		}

		return _wrapIndexes;
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

			if(!fontSettings.wordWrap) {
				g2.drawString(text, 0, 0);
			} else {
				var row = 0;
				for(c in wrapStrings(this, size)) {
					g2.drawString(c, 0, row*fontSettings.fontSize);
					row++;
				}
			}

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
	public var fontSize:Float = 16;
	public var wordWrap:Bool = false;
}

typedef WrapChunk = {begin:Int, end:Int};