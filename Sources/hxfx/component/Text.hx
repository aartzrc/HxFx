package hxfx.component;

import hxfx.core.NodeBase;

using StringTools;

@:bindable
class Text extends NodeBase {
	public static var wordWrapCharacters:Array<Int> = [32, 189]; // Space, dash

	public static inline var charWidthEstimate = 9/16;

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

		_wrapIndexes = null; // Clear cache
		layoutIsValid = false; // I changed, notify my parent
	}

	override public function layoutToSize(newLayoutSize:Size, force:Bool = false):Bool {
		if(!super.layoutToSize(newLayoutSize, force)) return false;

		// Layout has changed, rebuild character rectangles
		charRects = new Array<Rect>(); // Clear cache

		return true;
	}

	private override function _calcSize(layoutSize:Size) {
		return calcSize(this, layoutSize);
	}

	public static override function calcSize(textNode:Text, size:Size) {
		// Determine what size I want to be based on text size
		// Ignore most layout rules, the parent container will handle positioning
		
		// Start with how big NodeBase would be
		var newSize = NodeBase.calcSize(textNode, size);
		// Get how strings would wrap
		var minSize = new Size();
		wrapStrings(textNode, newSize, minSize);

		// Calc minimum size
		if(minSize.w > newSize.w) newSize.w = minSize.w;
		if(minSize.h > newSize.h) newSize.h = minSize.h;

		return newSize;
	}

	override function _thisHitBounds() {
		// Add a rectangle by default
		_hitBoundsCache.bounds.push(new Rect({position: {x:0, y:0}, size: {w:size.w, h:size.h}}));
	}

	private static function stringSize(textNode:Text, text:String) {
		var stringSize:Size = new Size();
		if(textNode.fontSettings.font != null) {
			stringSize.h = textNode.fontSettings.font.height(Math.round(textNode.fontSettings.fontSize));
			stringSize.w = textNode.fontSettings.font.width(Math.round(textNode.fontSettings.fontSize), text);
		} else {
			// No font? fake some size
			stringSize.h = textNode.fontSettings.fontSize;
			stringSize.w = charWidthEstimate*textNode.fontSettings.fontSize * text.length;
		}
		return stringSize;
	}

	/**
	 *  Get an array of strings that would be wrapped based on the given size.
	 *  Pass an empty Size instance for minSize, it will be populated with the minimum size to display all text
	 *  @param textNode - 
	 *  @param size - 
	 *  @param minSize - 
	 */
	public static function wrapStrings(textNode:Text, size:Size, ?minSize:Size) {
		var wrapStrings = new Array<String>();

		if(!textNode.fontSettings.wordWrap) { // No word wrap, just push back the full text and minimum size
			if(minSize != null) {
				var strSize = stringSize(textNode, textNode.text); // Calc minSize
				minSize.w = strSize.w;
				minSize.h = strSize.h;
			}
			return [textNode.text];
		} else {
			// Loop over text chunks - wrap when we hit an edge
			// TODO: this is a mess... rethink looping
			// Another approach would be to calc all string chunk sizes and find longest length first, then use that for target width - heavier for few wrapping lines, but quicker for smaller target sizes?
			var lastWrapPos = 0;
			var lastEndPos = 0;
			var targetSize = new Size({w:size.w, h:size.h});
			var strSize = new Size(); // Keep track of the total string size
			var lastTrySize = new Size();
			var wrapIndexes = textNode.wrapIndexes;
			var rebuild = false;
			var i = 0;
			while(i<wrapIndexes.length) {
				if(rebuild) {
					targetSize.w = strSize.w;
					wrapStrings = new Array<String>();
					lastWrapPos = 0;
					lastEndPos = 0;
					lastTrySize = new Size();
					i=0;
					rebuild = false;
				}
				var wrapChunk = wrapIndexes[i];
				var tryString = textNode.text.substring(lastWrapPos, wrapChunk.end);
				var trySize = stringSize(textNode, tryString);
				if(trySize.w > targetSize.w) {
					// Text has exceeded width, time to wrap!
					if(lastWrapPos != lastEndPos) { // A valid chunk has been found
						// Store the string
						wrapStrings.push(textNode.text.substring(lastWrapPos, lastEndPos));
						// Keep track of the size
						if(lastTrySize.w > strSize.w) {
							strSize.w = lastTrySize.w;
							// Size changed, repeat process
							rebuild = true;
						}
						// Update the position
						lastWrapPos = wrapChunk.begin;
						lastEndPos = wrapChunk.begin;
						i--; // Repeat the last chunk
					} else { // No valid chunk
						// TODO: Target width is smaller than current word, a flag is needed to start breaking into characters
						// For now store the string and adjust minimum size
						wrapStrings.push(textNode.text.substring(lastWrapPos, wrapChunk.end));
						// Keep track of the minimum size
						if(trySize.w > strSize.w) {
							strSize.w = trySize.w;
							// Size changed, repeat process
							rebuild = true;
						}
						// Move the pointer forward to the next chunk
						if(wrapIndexes.length > i+1) {
							var nextWrap = wrapIndexes[i+1];
							lastWrapPos = nextWrap.begin;
							lastEndPos = nextWrap.begin;
						}
					}
				} else {
					lastEndPos = wrapChunk.end;
					lastTrySize = trySize;
				}
				i++;
			}

			// Store the last chunk
			if(lastWrapPos != lastEndPos) {
				var tryString = textNode.text.substr(lastWrapPos);
				var trySize = stringSize(textNode, tryString);
				wrapStrings.push(tryString);
				if(trySize.w > strSize.w) strSize.w = trySize.w;
			}
			
			// Build the final height
			strSize.h = textNode.fontSettings.fontSize * wrapStrings.length;

			if(minSize != null) {
				minSize.w = strSize.w;
				minSize.h = strSize.h;
			}
		}

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
				//curString = curString.trim(); // Ignore spaces
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

		var wordChunks = wrapStrings(this, size);

		if(useFont != null) {
			var h = useFont.height(useFontSize);
			var row = 0;
			for(chunk in wordChunks) {
				x = 0;
				for(i in 1 ... chunk.length+1) {
					//var w = useFont.widthOfCharacters(useFontSize, charCodes, 0, i);
					var w = useFont.width(useFontSize, chunk.substr(0, i));
					charRects.push(new Rect({position: {x: x, y: row*h}, size: {w:w-x, h:h}}));
					x = w;
				}
				row ++;
			}
			//trace(charRects);
		} else {
			var row = 0;
			var cw = charWidthEstimate*fontSettings.fontSize; // Fake character width
			for(chunk in wordChunks) {
				x = 0;
				for(i in 1 ... chunk.length+1) {
					var w = i*cw;
					charRects.push(new Rect({position: {x: x, y: row*useFontSize}, size: {w:w-x, h:useFontSize}}));
					x = w;
				}
				row ++;
			}
		}

		// Push an extra rect for the end of the text
		charRects.push(new Rect({position: {x: x, y: (wordChunks.length-1)*useFontSize}, size: { w: 0, h: 16*(useFontSize/16) }}));

		return charRects;
	}

	override public function render(g2: Graphics): Void {
		super.render(g2);

		var useFont = fontSettings.font;

		if(useFont != null) {
			g2.font = useFont;
			g2.fontSize = Math.round(fontSettings.fontSize);
			// Adding font glyphs should be done at a higher level instead of during each Text.render call
			/*if(addFontGlyphs.length > 0) {
				for(i in addFontGlyphs) { // Check for extra font glyphs that are not in the current set
					if(g2.fontGlyphs.indexOf(i) == -1)
						g2.fontGlyphs.push(i);
				}
				fontGlyphs = g2.fontGlyphs; // Save the update
				addFontGlyphs = new Array<Int>(); // Clear the additions
			}*/
			
			g2.color = settings.color;

			//if(NodeBase.debug) g2.drawString(size.w + " : "+ size.h, 100, 100);
			
			var row = 0;
			for(c in wrapStrings(this, size)) {
				g2.drawString(c, 0, row*fontSettings.fontSize);
				row++;
			}
		}

		// Draw character rectangles - debug
		if(NodeBase.debugLayout) {
			g2.color = kha.Color.fromFloats(1,1,0,.5);
			for(r in characterRects) {
				g2.drawRect(r.position.x, r.position.y, r.size.w, r.size.h, 1);
			}
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