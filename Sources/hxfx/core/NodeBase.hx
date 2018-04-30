package hxfx.core;

import kha.input.KeyCode;

using kha.graphics2.GraphicsExtension;

/**
Root level class for a Display Node
The basic concept is:
1. A child changes (added to parent, layout change, some other update)
2. The node is marked layoutIsValid=false, the parent listens and propagates up the stack
3. At some point a fixed size container is reached (Window, Dialog, etc) - this fixed size container then blocks propagation and calls layoutToSize down the stack
4. When all layoutToSize calls complete the child will set layoutIsValid to true, which triggers the fixed size container to push a dirty rectangle up the stack
5. At the top of the stack (window/stage), the dirty rectangle is accepted and render engine processes
**/

class NodeBase implements IBindable  {
	public static var debugLayout:Bool = false;
	public static var debugHitbounds:Bool = false;
	public var visible:Bool;
	
	@:bindable
	public var settings:NodeBaseSettings;
	@:bindable(force)
	public var layoutSize(default, null):Size; // This is the last size this node was told to use for layout purposes (set during layoutToSize() call)
	@:bindable(force)
	public var size(default, null):Size; // This is the current actual size of the node - calculated by the node during layoutToSize
	@:bindable(force)
	public var scissorSize(default, null):Size; // This is the boundary size - calculated by the node during layoutToSize
	@:bindable
	public var layoutIsValid:Bool = true; // Used to check if current layout is valid - set to true in layoutToSize()
	@:bindable
	public var parent:NodeBase;
	@:bindable
	public var scale:Float = 1; // 96 or 72 dpi default?
	@:bindable
	public var cull:Bool; // Use for render culling, render updates won't be passed through - not implemented
	@:bindable
	public var focused:Bool = false; // Used to trace current focus path - keyboard events will feed down the focus path, similar to mouseSubscribe but for keyboard

	@:bindable
	public var mouseData:MouseData = null;
	@:bindable
	public var mouseSubscribe:Bool = false;

	private var _mouseListeners:Array<NodeBase> = new Array<NodeBase>(); // Children of this node that are listening for mouse events
	private var _childNodes = new Array<NodeBase>();
	private var _childPositions = new Map<NodeBase, Position>(); // Position lookup map

	public var redrawRects(default,null):Array<Rect>; // Use addRedrawRect() call to add redrawrects

	/* note, empty constructor was chosen so that instances could be initialized before parent was assigned
	assigning parent causes layout/etc to happen, set all initial values before assigning parent to avoid extra layout calls
	*/
	public function new(?useSettings:NodeBaseSettings) {
		if(useSettings == null) {
			settings = new NodeBaseSettings();
		} else {
			settings = useSettings;
		}
		size = new Size({});
		scissorSize = new Size({});
		layoutSize = new Size({});
		redrawRects = new Array<Rect>();
		Bind.bindAll(this.settings, _settings_Changed);
		Bind.bind(this.settings.cursor, _doCursorChanged);
		Bind.bind(this.parent, _parentChange);
		Bind.bind(this.mouseSubscribe, _mouseSubscribe);

		// Debug in bounds
		/*mouseSubscribe = true;
		Bind.bind(this.mouseData.mouseInBounds, _debugBounds);*/
	}

	private function _debugBounds(from:Bool, to:Bool) {
		// Do a redraw - render will highlight in bounds nodes
		layoutIsValid = false;
	}

	private function _parentChange(from:NodeBase, to:NodeBase) {
		if(from != null) {
			// Remove myself from the previous parent (parent.removeNode will unbind and remove mouse listener)
			from.removeNode(this);
			// Unbind from the parent
			Bind.unbindAll(from);
		}
		
		// Add myself to the parent (parent.addNode will bind)
		to.addNode(this);
		// Do I have any mouse listeners to manage, or am I subscribing to mouse events? Tell my new parent
		if(_mouseListeners.length > 0 || mouseSubscribe) {
			to.addMouseListener(this);
		}
	}

	/**
	Do calculations and pass sizes to children.
	The size passed is the available space for this node, this node will then use LayoutRules or other custom code to calculate it's size within the given space
	**/
	public function layoutToSize(newLayoutSize:Size, force:Bool = false):Bool {
		if(layoutSize == newLayoutSize && layoutIsValid && !force) {
			return false; // Already at this size and layout is valid, no update needed
		}

		layoutSize = newLayoutSize;

		// Update the size this node will use for display
		var newSize = _calcSize(newLayoutSize);

		// Copy values so bindings are maintained
		size.w = scissorSize.w = newSize.w;
		size.h = scissorSize.h = newSize.h;

		// Reset the bounds cache
		_hitBoundsCache = null;

		// Update my children based on the new size calculated - children are allowed to push the parent node larger, scissorSize is used to hide overflow
		newSize = _calcChildLayout(newSize);

		// Copy values so bindings are maintained
		size.w = newSize.w;
		size.h = newSize.h;

		// Parent listenes to layoutIsValid switching to true and calls render engine to update display
		layoutIsValid = true;

		return true;
	}
	
	/**
	Calculate node size based on the available space provided by the parent
	Override this call for subclasses that have specific size rules
	**/
	public static function calcSize(node:NodeBase, layoutSize:Size) {
		var newSize = new Size();

		// Determine what size I want to be based on my layout rules
		// Position is handled by the parent!

		switch(node.settings.width) {
			case LayoutSize.Fixed(v):
				newSize.w=v;
			case LayoutSize.Percent(v):
				newSize.w = layoutSize.w*(v/100);
			case LayoutSize.PercentLessFixed(p, f):
				newSize.w = (layoutSize.w - f) * (p/100);
		}
		switch(node.settings.height) {
			case LayoutSize.Fixed(v):
				newSize.h=v;
			case LayoutSize.Percent(v):
				newSize.h = layoutSize.h*(v/100);
			case LayoutSize.PercentLessFixed(p, f):
				newSize.h = (layoutSize.h - f) * (p/100);
		}

		if(newSize.w < 0) newSize.w = 0;
		if(newSize.h < 0) newSize.h = 0;

		return newSize;
	}

	private function _calcSize(layoutSize:Size) {
		return calcSize(this, layoutSize);
	}

	/**
	Determine child sizes and positions - by default give all children full view of the container and ignore children being larger/outside parent boundaries
	Override this call for subclasses that have specific layout rules
	**/
	private function _calcChildLayout(targetSize:Size) {
		for(child in _childNodes) {
			child.layoutToSize(targetSize);

			var childPos = _childPositions.get(child);

			// Child has determined how big it wants to be, now position it based on rules available
			switch(child.settings.alignX) {
				case Align.FixedLT(v):
					childPos.x = v;
				case Align.FixedM(v):
					childPos.x = -(child.size.w / 2) + v;
				case Align.FixedRB(v):
					childPos.x = -child.size.w + v;
				case Align.PercentLT(v):
					childPos.x = (size.w * (v/100));
				case Align.PercentM(v):
					childPos.x = (size.w * (v/100)) - (child.size.w/2); // Calc to middle of parent node, then move left 1/2 of child node size
				case Align.PercentRB(v):
					childPos.x = (size.w * (v/100)) - child.size.w;
				case Align.PercentLTLessFixed(p, f):
					childPos.x = (size.w - f) * (p/100);
			}
			switch(child.settings.alignY) {
				case Align.FixedLT(v):
					childPos.y = v;
				case Align.FixedM(v):
					childPos.y = -(child.size.h / 2) + v;
				case Align.FixedRB(v):
					childPos.y = -child.size.h + v;
				case Align.PercentLT(v):
					childPos.y = (size.h * (v/100));
				case Align.PercentM(v):
					childPos.y = (size.h * (v/100)) - (child.size.h/2); // Calc to middle of parent node, then move left 1/2 of child node size
				case Align.PercentRB(v):
					childPos.y = (size.h * (v/100)) - child.size.h;
				case Align.PercentLTLessFixed(p, f):
					childPos.y = (size.h - f) * (p/100);
			}
		}

		// Grow the final size to fit all children
		if(settings.fitToChildren) {
			for(child in _childNodes) {
				// Adjust target size to cover all children
				var childPos = _childPositions.get(child);
				if(childPos.x + child.size.w > targetSize.w) targetSize.w = childPos.x + child.size.w;
				if(childPos.y + child.size.h > targetSize.h) targetSize.h = childPos.y + child.size.h;
			}
		}

		return targetSize;
	}

	public function addRedrawRect(redrawRect:Rect) {
		// TODO: optimize redraw rects instead of push
		// Look at overlaps/etc and reduce/merge the rectangles
		redrawRects.push(redrawRect);
	}

	public function clearRedrawRequest() {
		redrawRects = new Array<Rect>();
		//redrawRequested = false;
	}

	public var children(get, never):Array<NodeBase>;

	function get_children() {
		return _childNodes;
	}

	private function addNode(childNode:NodeBase):Void {
		// Check if child is already attached
		if(_childNodes.indexOf(childNode) != -1) return;
		_childNodes.push(childNode);
		_childPositions.set(childNode, new Position());
		Bind.bind(childNode.layoutIsValid, _childLayoutIsValidChanged);
		Bind.bind(childNode.focused, _childFocusedChanged);
		if(childNode.focused) this.focused = true;
		layoutIsValid = false; // Notify my parent that I have changed
	}

	private function removeNode(childNode:NodeBase):Bool {
		// Search for matching child and remove
		if(!_childNodes.remove(childNode))
			return false;

		_childPositions.remove(childNode);
		Bind.unbind(childNode.layoutIsValid, _childLayoutIsValidChanged);
		Bind.unbind(childNode.focused, _childFocusedChanged);
		if(childNode.focused) this.focused = false;

		// If child is a mouse listener, detach
		if(_mouseListeners.indexOf(childNode) != -1) {
			removeMouseListener(childNode);
		}
		layoutIsValid = false; // Notify my parent that I have changed
		
		return true;
	}

	/**
	 *  Reposition child within render list
	 *  @param childNode - 
	 *  @param index - 
	 *  @return Bool
	 */
	public function setChildIndex(childNode:NodeBase, index:Int):Bool {
		if(_childNodes.indexOf(childNode) == -1 || _childNodes.indexOf(childNode) == index) return false;
		_childNodes.remove(childNode);
		_childNodes.insert(index, childNode);
		layoutIsValid = false; // Notify my parent that I have changed
		return true;
	}

	public function clearChildren() {
		for(c in _childNodes) {
			c.parent = null;
		}
	}

	private function _childLayoutIsValidChanged(from:Bool, to:Bool) {
		// Propagate up stack by default - a fixed size container (window/dialog/etc) up the stack can override this and begin layout call back down stack (see Stage for an example)
		if(!to) {
			layoutIsValid = false;
		}
	}

	private function _childFocusedChanged(from:Bool, to:Bool) {
		// Propagate up stack - the top level container will pass keyboard events down 'focused' chain
		this.focused = to;
	}

	public function _settings_Changed(origin:IBindable, name:String, from:Dynamic, to:Dynamic) {
		// TODO: only invalidate for settings that cause layout to changes - child classes will need to override this to handle special cases for their class
		layoutIsValid = false; // Notify parent I need to adjust my layout
	}

	/**
	 *  Callback for when settings.cursor changes
	 *  @param from - 
	 *  @param to - 
	 */
	private function _doCursorChanged(from:String, to:String) {
		if(to != null) {
			// Set to a value, subscribe to mouse and start cursor update bind
			mouseSubscribe = true;
			Bind.bind(this.mouseData.mouseInBounds, _updateCursor);
		} else {
			Bind.unbind(this.mouseData.mouseInBounds, _updateCursor);
		}
	}

	/**
	 *  Callback to update cursor when mouse is in-bounds
	 *  @param from - 
	 *  @param to - 
	 */
	private function _updateCursor(from:Bool, to:Bool) {
		if(to == false) {
			parent.setCursor(null);
		} else {
			parent.setCursor(settings.cursor);
		}
	}

	/**
	 *  Pass the new cursor up the stack
	 *  @param cursorName - 
	 */
	public function setCursor(cursorName:String) {
		// Any validation here?
		parent.setCursor(cursorName);
		// Cursor type is held on a stack in the Window object, so moving between nodes that have different cursors should be clean
	}

	/** 
	Handle changes to mouseSubscribe field - attach/detach from parent
	MouseData is requested up the chain to the Stage/Window
	**/
	private function _mouseSubscribe(from: Bool, to: Bool) {
		if(mouseData == null) {
			mouseData = new MouseData();
			Bind.bindAll(mouseData, _doMouseChanged);
		}
		if(to) {
			if(parent != null) {
				parent.addMouseListener(this);
			}
		} else {
			if(parent != null) {
				parent.removeMouseListener(this);
			}
		}
	}

	public function addMouseListener(child:NodeBase) {
		// Child is attached and a mouseListener has not been created
		if(_childNodes.indexOf(child)>=0 && _mouseListeners.indexOf(child) == -1) {
			// Lazy create mouseData for myself
			if(mouseData == null) {
				mouseData = new MouseData();
			}
			// Bind all events, this will translate the events to the child node
			Bind.bindAll(mouseData, _doMouseChanged);
			_mouseListeners.push(child);
			// Push the request up the chain
			if(parent != null) {
				parent.addMouseListener(this);
			}
		}
	}

	public function removeMouseListener(child:NodeBase) {
		// Remove the child
		_mouseListeners.remove(child);
		// Check if we should start ignoring mouseData changes
		if(_mouseListeners.length == 0 && !this.mouseSubscribe) {
			Bind.unbindAll(mouseData);
		}
	}

	private function _doMouseChanged(origin:IBindable, name:String, from:Dynamic, to:Dynamic) {
		if(name == "mouseInBounds") return; // Ignore the mouseInBounds field
		for(l in _mouseListeners) {
			var childPos = _childPositions.get(l);
			l.mouseData.x = mouseData.x - childPos.x;
			l.mouseData.y = mouseData.y - childPos.y;
			l.mouseData.xd = mouseData.xd;
			l.mouseData.yd = mouseData.yd;
			l.mouseData.b1down = mouseData.b1down;
			l.mouseData.b2down = mouseData.b2down;
			l.mouseData.b3down = mouseData.b3down;
			l.mouseData.wheeld = mouseData.wheeld;
			l.mouseData.wheel = mouseData.wheel;
			l.mouseData.b1doubleclicked = mouseData.b1doubleclicked;
		}

		// TODO: check children for in bounds too? or maybe a separate property for children vs current node mouse in bounds?
		// Bounds should be a shape instead of rectangle
		/*if(mouseData.x>=0 && mouseData.x<=size.w && mouseData.y>=0 && mouseData.y<=size.h) {
			mouseData.mouseInBounds = true;
		} else {
			mouseData.mouseInBounds = false;
		}*/
	}

	function _checkMouseInBounds():Bool {
		if(mouseData != null) {
			// Check if this node is in bounds
			var inBounds = hitBounds.inBounds(new Position({x: mouseData.x, y: mouseData.y}), settings.overflowHidden ? scissorSize : null);

			mouseData.mouseInBounds = inBounds;

			// This node is in bounds, find which child is in bounds
			if(inBounds) {
				var foundChildInBounds = false;
				var i = _childNodes.length-1; // Run bounds check reverse from display order (last drawn should have first bounds check)
				while(i>=0) {
					var c = _childNodes[i];
					// Check the child, it will set its in bounds flag
					if(!foundChildInBounds && c._checkMouseInBounds()) {
						// Stop looking when the child is found
						foundChildInBounds = true;
					} else {
						// Clear all child in bounds flags
						c._clearMouseInBounds();
					}
					i--;
				}

				return true;
			}

			return inBounds;
		}
		return false;
	}

	function _clearMouseInBounds() {
		if(mouseData != null) {
			mouseData.mouseInBounds = false;
		}
		for(c in _childNodes) {
			c._clearMouseInBounds();
		}
	}

	var _hitBoundsCache:HitBounds;

	public var hitBounds(get,never):HitBounds;

	function get_hitBounds() {
		if(_hitBoundsCache != null) return _hitBoundsCache;

		_hitBoundsCache = new HitBounds();
		_thisHitBounds();
		for(c in children) {
			// Get and translate the child hitbounds into this bounds
			var childBounds = c.hitBounds;
			for(b in childBounds.bounds) {
				_hitBoundsCache.bounds.push(b.translate(_childPositions[c]));
			}
		}

		return _hitBoundsCache;
	}

	/**
	 *  Child classes should override this for custom hit bounds
	 */
	function _thisHitBounds() {
		// NodeBase does not have boundaries by default
	}

	private function _keysDownChange(keysDown:List<KeyCode>) {
		// Look for the child with focus
		for(c in _childNodes) {
			if(c.focused) {
				c._keysDownChange(keysDown);
				return;
			}
		}
	}

	private function _keyPressed(k:String) {
		// Look for the child with focus
		for(c in _childNodes) {
			if(c.focused) {
				c._keyPressed(k);
				return;
			}
		}
	}

	private function cutListener():String {
		// Look for the child with focus
		for(c in _childNodes) {
			if(c.focused) {
				return c.cutListener();
			}
		}
		return null;
	}

	private function copyListener():String {
		// Look for the child with focus
		for(c in _childNodes) {
			if(c.focused) {
				return c.copyListener();
			}
		}
		return null;
	}

	private function pasteListener(paste:String) {
		// Look for the child with focus
		for(c in _childNodes) {
			if(c.focused) {
				c.pasteListener(paste);
				return;
			}
		}
	}

	public function render(g2: Graphics): Void {
		// Draw myself - clear to my background color
		// TODO: this should only clear invalid rects for the area within this node

		// Scissor is tricky, no push/pop stack and translations are not handled
		// TODO: create a scissor stack that can be used to hide overflow in children
		if(settings.overflowHidden) {
			g2.scissor(Math.floor(g2.transformation._20)-1, Math.floor(g2.transformation._21)-1, Math.ceil(scissorSize.w)+2, Math.ceil(scissorSize.h)+2);
		}

		if(settings.bgColor.A > 0) {
			var _c = g2.color;
			g2.color = settings.bgColor;
			g2.fillRect(0,0,size.w,size.h);
			g2.color = _c;
		}

		_renderChildren(g2);

		if(settings.overflowHidden) {
			g2.disableScissor();
		}

		if(settings.overflowHidden && debugLayout) {
			var _c = g2.color;
			g2.color = kha.Color.fromFloats(0,0,1,.5);
			g2.drawRect(0, 0, scissorSize.w, scissorSize.h, 2);
			g2.color = _c;
		}
		
		// Debug rectangle
		if(debugLayout) {
			var _c = g2.color;
			g2.color = kha.Color.fromFloats(0,0,0,.2);
			g2.drawRect(0,0,size.w,size.h);
			g2.color = _c;
		}
		/*if(debugHitbounds) {
			var _c = g2.color;
			g2.color = kha.Color.fromFloats(1,0,0,.2);
			for(b in hitBounds.bounds) {
				// Not a great way to determine type...
				try {
					var r = cast(b, Rect);
					if(mouseData.mouseInBounds) g2.fillRect(r.position.x,r.position.y,r.size.w,r.size.h);
					g2.drawRect(r.position.x,r.position.y,r.size.w,r.size.h);
				} catch(e:Dynamic) {
					try {
						var c = cast(b, Circle);
						if(mouseData.mouseInBounds) g2.fillCircle(c.position.x, c.position.y, c.radius);
						g2.drawCircle(c.position.x, c.position.y, c.radius);
					} catch(e:Dynamic) {
					}
				}
			}
			g2.color = _c;
		}*/
	}

	function _renderChildren(g2:Graphics) {
		for(child in _childNodes) {
			// TODO: Calc redraw based on invalid rects? 
			// Use renderIsValid?
			// Pass rects down chain (with translation) and each node can choose which children to render?
			var childPos = _childPositions.get(child);
			g2.pushTranslation(childPos.x, childPos.y);
			child.render(g2);
			g2.popTransformation();
		}
	}
}

/** 
Use 'standard' 12pt, 16px, 1em, 100% size concept at 96/72dpi? - for example: https://websemantics.uk/articles/font-size-conversion/
All font sizes would be based on this, font size is float - 1.0 == 1em size
Width/height sizes are same, 1.0 float == 16px
**/

enum LayoutSize {
	Fixed(v:Float); // A fixed width
	Percent(v:Float); // A percent width relative to the provided layout area (typically the parents full layout space)
	PercentLessFixed(percent:Float, fixed:Float); // Reduce the dimension by the fixed value, then use percent size
}

enum Align {
	FixedLT(v:Float); // Left or top edge of node is in a fixed position
	FixedM(v:Float); // Middle of node is in a fixed position
	FixedRB(v:Float); // Right or bottom edge of node is in a fixed position
	PercentLT(v:Float); // Left or top edge of node is a percent position from left or top of layout area
	PercentM(v:Float); // Middle of node is a percent position from left of layout area
	PercentRB(v:Float); // Right or bottom edge of node is a percent position from right or bottom of layout area
	PercentLTLessFixed(percent:Float, fixedFloat:Float); // Reduce the dimension by the fixed value, then use percent size
}

@:bindable
class NodeBaseSettings implements IBindable {
	public var width:LayoutSize = Fixed(0);
	public var height:LayoutSize = Fixed(0);
	public var alignX:Align = PercentM(50);
	public var alignY:Align = PercentM(50);
	public var bgColor:Color = kha.Color.Transparent;
	public var color:Color = kha.Color.Transparent;
	public var cursor:String = null; // Cursor/pointer - in html target, this pushes to the DOM - see cursor names here: https://www.w3schools.com/cssref/playit.asp?filename=playcss_cursor&preval=copy
	public var overflowHidden:Bool = false; // Scissor based on LayoutSize
	public var fitToChildren:Bool = false; // NodeBase final size will fit all children inside

	public function new() {
		// Any init/defaults?
	}
}
