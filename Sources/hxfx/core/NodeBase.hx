package hxfx.core;

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
	@:bindable(force)
	public var layoutSize(default, null):Size; // This is the last size this node was told to use for layout purposes (set during layoutToSize() call)
	@:bindable(force)
	public var size(default, null):Size; // This is the current actual size of the node - calculated by the node during layoutToSize
	@:bindable
	public var layoutIsValid:Bool = true; // Used to check if current layout is valid - set to true in layoutToSize()
	@:bindable
	public var parent:NodeBase;
	@:bindable
	public var scale:Float = 1; // 96 dpi default?
	@:bindable
	public var cull:Bool; // Use for render culling, render updates won't be passed through - not implemented
	@:bindable(force)
	// Review layout system - use a rule/override system with bindings to some top level objects to reproduce css type updates?
	public var layoutRules(default,null):Array<LayoutRule>;

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
	public function new() {
		size = new Size({});
		layoutSize = new Size({});
		layoutRules = new Array<LayoutRule>();
		redrawRects = new Array<Rect>();
		//Bind.bind(this.layoutRules, _layoutRulesChange);
		Bind.bind(this.parent, _parentChange);
		Bind.bind(this.mouseSubscribe, _mouseSubscribe);
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
		size = _calcSize(newLayoutSize);

		// Update my children based on the final size calculated
		_calcChildLayout();

		// Parent listenes to layoutIsValid switching to true and calls render engine to update display
		layoutIsValid = true;

		return true;
	}
	
	/**
	Calculate node size based on the available space provided by the parent
	Override this call for subclasses that have specific size rules
	**/
	public static function calcSize(node:NodeBase, layoutSize:Size) {
		var newSize = new Size({w:0, h:0});

		// Determine what size I want to be based on my layout rules
		// Position is handled by the parent!
		for(rule in node.layoutRules) {
			switch(rule) {
				case LayoutRule.Width(LayoutSize.Fixed(v)):
					newSize.w = v;
				case LayoutRule.Width(LayoutSize.Percent(v)):
					newSize.w = layoutSize.w*(v/100);
				case LayoutRule.Height(LayoutSize.Fixed(v)):
					newSize.h = v;
				case LayoutRule.Height(LayoutSize.Percent(v)):
					newSize.h = layoutSize.h*(v/100);
				case _:
					// Ignore rules we don't know how to handle
					//trace(rule);
			}
		}

		return newSize;
	}

	private function _calcSize(layoutSize:Size) {
		return calcSize(this, layoutSize);
	}

	/**
	Determine child sizes and positions - by default give all children full view of the container and ignore children being larger/outside parent boundaries
	Override this call for subclasses that have specific layout rules
	**/
	private function _calcChildLayout() {
		for(child in _childNodes) {
			child.layoutToSize(new Size({w:size.w, h:size.h}));

			var childPos = _childPositions.get(child);

			// Child has determined how big it wants to be, now position it based on rules available
			for(rule in child.layoutRules) {
				switch(rule) {
					case LayoutRule.HAlign(Align.PercentMiddle(v)):
						childPos.x = (size.w-child.size.w) * (v/100);
					case LayoutRule.VAlign(Align.PercentMiddle(v)):
						childPos.y = (size.h-child.size.h) * (v/100);
					case LayoutRule.HAlign(Align.FixedLT(v)):
						childPos.x = v;
					case LayoutRule.VAlign(Align.FixedLT(v)):
						childPos.y = v;
					case LayoutRule.HAlign(Align.FixedM(v)):
						childPos.x = -(child.size.w / 2) + v;
					case LayoutRule.VAlign(Align.FixedM(v)):
						childPos.y = -(child.size.h / 2) + v;
					case LayoutRule.HAlign(Align.FixedRB(v)):
						childPos.x = -child.size.w + v;
					case LayoutRule.VAlign(Align.FixedRB(v)):
						childPos.y = -child.size.h + v;
					case _:
						// Ignore rules we don't know how to handle
						//trace(rule);
				}
			}
		}
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

	private function addNode(childNode:NodeBase):Void {
		// Check if child is already attached
		if(_childNodes.indexOf(childNode) != -1) return;

		_childNodes.push(childNode);
		_childPositions.set(childNode, new Position({x:0, y:0}));
		Bind.bind(childNode.layoutIsValid, _childLayoutIsValidChanged);
		layoutIsValid = false; // Notify my parent that I have changed
	}

	private function removeNode(childNode:NodeBase):Bool {
		// Search for matching child and remove
		if(!_childNodes.remove(childNode))
			return false;

		_childPositions.remove(childNode);
		Bind.unbind(childNode.layoutIsValid, _childLayoutIsValidChanged);

		// If child is a mouse listener, detach
		if(_mouseListeners.indexOf(childNode) != -1) {
			removeMouseListener(childNode);
		}
		layoutIsValid = false; // Notify my parent that I have changed
		
		return true;
	}

	private function _childLayoutIsValidChanged(from:Bool, to:Bool) {
		// Propagate up stack by default - a fixed size container (window/dialog/etc) up the stack can override this and begin layout call back down stack (see Stage for an example)
		layoutIsValid = false;
	}

	public function setLayoutRule(newRule:LayoutRule) {
		// TODO: check for other rules that should be removed during this update
		layoutRules.push(newRule);
		// Return previous rule if one was removed?

		// If cursor is changing to non-default begin listening to mouse
		switch(newRule) {
			case LayoutRule.Cursor(cursorName):
				mouseSubscribe = true;
				// Watch mouse and adjust cursor
				bindx.Bind.bind(this.mouseData.mouseInBounds, _updateCursor);
			case _:
		}

		layoutIsValid = false; // Notify parent I need to adjust my layout
	}

	private function _updateCursor(from:Bool, to:Bool) {
		if(to == false) {
			parent.setCursor(null);
		} else {
			for(r in layoutRules) {
				switch(r) {
					case LayoutRule.Cursor(cursorName):
						parent.setCursor(cursorName);
					case _:
						// Ignore other rules
				}
			}
		}
	}

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
		}

		// TODO: check children for in bounds too? or maybe a separate property for children vs current node mouse in bounds?
		// Bounds should be a shape instead of rectangle
		if(mouseData.x>=0 && mouseData.x<=size.w && mouseData.y>=0 && mouseData.y<=size.h) {
			mouseData.mouseInBounds = true;
		} else {
			mouseData.mouseInBounds = false;
		}
	}

	public function render(g2: Graphics): Void {
		// Draw myself - clear to my background color
		// TODO: this should only clear invalid rects for the area within this node
		// TODO: background is a layoutRule, should it be cached or loop through all layoutRules during rendering?
		var bgColor = kha.Color.Transparent;
		for(r in layoutRules) {
			switch(r) {
				case LayoutRule.BackgroundColor(c):
					bgColor = c;
				case _:
					// Ignore other rules
			}
		}
		if(bgColor.A > 0) {
			var _c = g2.color;
			g2.color = bgColor;
			g2.fillRect(0,0,size.w,size.h);
			g2.color = _c;
		}

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