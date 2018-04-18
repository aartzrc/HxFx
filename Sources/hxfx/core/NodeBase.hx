package hxfx.core;

/**
Root level class for a Display Node
Add/remove child nodes
All children will receive messages?
All children will get render call?
**/
class NodeBase implements IBindable  {
	@:bindable(force)
	public var minSize(default,null):Size; // This is the minimum size this node wants to be - the parent can decide to make it smaller and handle overflow
	@:bindable(force)
	public var layoutSize(default, null):Size; // This is the last size this node was told to use for layout purposed (set during layoutToSize() call)
	@:bindable
	public var redrawRequested:Bool = false;
	@:bindable
	public var parent:NodeBase;
	@:bindable
	public var scale:Float = 1; // 96 dpi default
	@:bindable
	public var cull:Bool; // Use for render culling, render updates won't be passed through
	@:bindable(force)
	// Rethink layout - use a rule/override system with bindings to some top level objects to reproduce css type updates?
	public var layoutRules(default,null):Array<LayoutRule>;

	@:bindable
	public var mouseData:MouseData = null;
	@:bindable
	public var mouseSubscribe:Bool = false;

	private var mouseListeners:Array<NodeBase> = new Array<NodeBase>();
	private var _childNodes = new Array<Layout.ChildNode>();

	public var redrawRects(default,null):Array<Rect>; // Use addRedrawRect() call to add redrawrects

	/* note, empty constructor was chosen so that instances could be initialized before parent was assigned
	assigning parent causes a full invalid rect to be pushed, set all initial values before assigning parent to avoid invalid rect duplication
	*/
	public function new() {
		minSize = new Size({});
		layoutSize = new Size({});
		layoutRules = new Array<LayoutRule>();
		redrawRects = new Array<Rect>();
		//Bind.bind(this.layoutRules, _layoutRulesChange);
		Bind.bind(this.parent, _parentChange);
		Bind.bind(this.mouseSubscribe, _mouseSubscribe);
	}

	private function _parentChange(from:NodeBase, to:NodeBase) {
		if(from != null) {
			// Remove myself from the previous parent (parent.removeNode will unbind)
			from.removeNode(this);
			// Unbind from the parent
			Bind.unbindAll(from);
			// If I'm a mouse listener, detach
			if(from.mouseListeners.indexOf(this) != -1) {
				from.removeMouseListener(this);
			}
		}
		
		// Add myself to the parent (parent.addNode will bind)
		to.addNode(this);
		// Do I have any mouse listeners to manage, or am I subscribing to mouse events? Tell my new parent
		if(mouseListeners.length > 0 || mouseSubscribe) {
			to.addMouseListener(this);
		}
	}

	/**
	Do calculations and pass sizes to children.
	The size passed is the available space for this node, this node will then use LayoutRules to calculate it's size within the given space
	**/
	public function layoutToSize(size:Size):Bool {
		if(layoutSize == size) return false; // Already at this size

		// Determine what size I want to be based on my layout rules
		// Position is handled by the parent!
		for(rule in layoutRules) {
			switch(rule) {
				case LayoutRule.Width(LayoutSize.Fixed(v)):
					size.w = v;
				case LayoutRule.Width(LayoutSize.Percent(v)):
					size.w*=(v/100);
				case LayoutRule.Height(LayoutSize.Fixed(v)):
					size.h = v;
				case LayoutRule.Height(LayoutSize.Percent(v)):
					size.h*=(v/100);
				case _:
					// Ignore rules we don't know how to handle
					//trace(rule);
			}
		}

		// Update the size I will use
		layoutSize = _calcSize(size);

		// Notify my parent that I need to be redrawn
		addRedrawRect(new Rect({position: { x: 0, y:0 }, size:{ w: layoutSize.w, h: layoutSize.h }}));

		// Update my children
		_recalcChildLayout();

		// TODO: update minSize - how to handle children minSize combinations?

		return true;
	}

	/**
	Calculate my size based on the available space provided by the parent
	Override this call for subclasses that have specific size rules
	**/
	private function _calcSize(size:Size) {

		// Determine what size I want to be based on my layout rules
		// Position is handled by the parent!
		for(rule in layoutRules) {
			switch(rule) {
				case LayoutRule.Width(LayoutSize.Fixed(v)):
					size.w = v;
				case LayoutRule.Width(LayoutSize.Percent(v)):
					size.w*=(v/100);
				case LayoutRule.Height(LayoutSize.Fixed(v)):
					size.h = v;
				case LayoutRule.Height(LayoutSize.Percent(v)):
					size.h*=(v/100);
				case _:
					// Ignore rules we don't know how to handle
					//trace(rule);
			}
		}

		return size;
	}

	private function addNode(childNode:NodeBase):Void {
		// Check if child is already attached
		if(_childIndex(childNode) != -1) return;

		var emptyRect = new Rect({position: {x:0, y:0}, size: {w:0, h:0}});
		_childNodes.push({child:childNode, rect:emptyRect});
		Bind.bindAll(childNode, _childPropertyChanged);
		if(_recalcChildLayout()) {
			//trace("HERE");
			//childNode.redrawRequested = true;
		}
	}

	private function _recalcChildLayout():Bool {
		// Recalc child sizes and positions - by default give all children full view of the container
		var redraw = false;
		var allRect = new Rect({position: {x:0, y:0}, size: {w:layoutSize.w, h:layoutSize.h}});
		for(cn in _childNodes) {
			if(cn.rect != allRect) {
				cn.rect = allRect;
				if(cn.child.layoutToSize(cn.rect.size)) redraw = true;

				// Child has determined how big it wants to be, now position it based on rules available
				for(rule in cn.child.layoutRules) {
					switch(rule) {
						case LayoutRule.HAlign(Align.PercentMiddle(v)):
							cn.rect.position.x = (layoutSize.w-cn.child.layoutSize.w) * (v/100);
						case LayoutRule.VAlign(Align.PercentMiddle(v)):
							cn.rect.position.y = (layoutSize.h-cn.child.layoutSize.h) * (v/100);
						case _:
							// Ignore rules we don't know how to handle
							//trace(rule);
					}
				}
			}
		}

		return redraw;
	}

	private function _childPropertyChanged(origin:IBindable, name:String, from:Dynamic, to:Dynamic) {
		var child = cast(origin, NodeBase);
		switch(name) {
			case "redrawRequested":
				// Determine if redraw is needed? For now just push it up the stack
				redrawRects.concat(child.redrawRects);
				child.clearRedrawRequest(); // Redraw acknowledged, clear it
				redrawRequested = true;
			case "layoutRules":
				// Should a layout change propagate up the stack? Maybe based on different rules for each container...
				_recalcChildLayout();
			case _:
				//trace(name);
		}
	}

	public function addRedrawRect(redrawRect:Rect) {
		// TODO: optimize redraw rects instead of push
		// Look at overlaps/etc and reduce/merge the rectangles
		redrawRects.push(redrawRect);
	}

	public function clearRedrawRequest() {
		redrawRects = new Array<Rect>();
		redrawRequested = false;
	}

	private function removeNode(childNode:NodeBase):Bool {
		// Search for matching child and remove
		var childIndex = _childIndex(childNode);
		if(childIndex == -1) return false;

		_childNodes.splice(childIndex, 1);

		Bind.unbindAll(childNode);
		
		return true;
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
				bindx.Bind.bind(this.mouseData.mouseInBounds, updateCursor);
			case _:
		}

		Bind.notify(this.layoutRules, [], [newRule]);
	}

	function updateCursor(from:Bool, to:Bool) {
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
		var childIndex = _childIndex(child);

		// Child is attached and a mouseListener has not been created
		if(childIndex>=0 && mouseListeners.indexOf(child) == -1) {
			// Lazy create mouseData for myself
			if(mouseData == null) {
				mouseData = new MouseData();
			}
			// Bind all events, this will translate the events to the child node
			Bind.bindAll(mouseData, _doMouseChanged);
			mouseListeners.push(child);
			// Push the request up the chain
			if(parent != null) {
				parent.addMouseListener(this);
			}
		}
	}

	public function removeMouseListener(child:NodeBase) {
		// Remove the child
		mouseListeners.remove(child);
		// Check if we should start ignoring mouseData changes
		if(mouseListeners.length == 0 && !this.mouseSubscribe) {
			Bind.unbindAll(mouseData);
		}
	}

	private function _doMouseChanged(origin:IBindable, name:String, from:Dynamic, to:Dynamic) {
		for(l in mouseListeners) {
			var childPos = _childRect(l).position;
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
		if(mouseData.x>=0 && mouseData.x<=layoutSize.w && mouseData.y>=0 && mouseData.y<=layoutSize.h) {
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
			g2.fillRect(0,0,layoutSize.w,layoutSize.h);
			g2.color = _c;
		}

		for(c in _childNodes) {
			// TODO: Calc redraw based on invalid rects? 
			// Pass rects down chain (with translation) and each node can choose which children to render?
			var childPos = c.rect.position;
			g2.pushTranslation(childPos.x, childPos.y);
			c.child.render(g2);
			g2.popTransformation();
		}
	}

	private function _childIndex(childNode:NodeBase):Int {
		for(i in 0 ... _childNodes.length) {
			if(_childNodes[i].child == childNode) {
				return i;
			}
		}

		return -1;
	}

	private function _childRect(childNode:NodeBase):Rect {
		for(i in 0 ... _childNodes.length) {
			if(_childNodes[i].child == childNode) {
				return _childNodes[i].rect;
			}
		}

		return null;
	}
}