package hxfx.core;

/**
Root level class for a Display Node
Add/remove child nodes
All children will receive messages?
All children will get render call?
**/
class NodeBase implements IBindable  {
	// Stores the current width and height - this will be adjusted based on NodeLayout input and should be read only
	@:bindable(force)
	public var size(default,null):Size;
	@:bindable
	public var parent:NodeBase;
	@:bindable
	public var scale:Float = 1; // 96 dpi default
	@:bindable
	public var cull:Bool; // Use for render culling, render updates won't be passed through
	@:bindable
	public var layout:Layout; // Rethink layout - use a rule/override system with bindings to some top level objects to reproduce css type updates?
	public var backgroundColor:Color = Color.White;

	@:bindable
	public var mouseData:MouseData = null;
	@:bindable
	public var mouseSubscribe:Bool = false;
	@:bindable
	public var mouseInBounds:Bool = false;
	public var mouseListeners:Array<NodeBase> = new Array<NodeBase>();

	private var _childNodes = new Map<NodeBase, Position>();

	/* note, empty constructor was chosen so that instances could be initialized before parent was assigned
	assigning parent causes a full invalid rect to be pushed, set all initial values before assigning parent to avoid invalid rect duplication
	*/
	public function new() {
		size = new Size({});
		layout = new Layout();
		Bind.bind(this.layout, _layoutChange);
		Bind.bind(this.parent, _parentChange);
		Bind.bind(this.mouseSubscribe, _mouseSubscribe);
	}

	private function doParentPropertyChange(origin:IBindable, name: String, from:Dynamic, to:Dynamic) {
		switch(name) {
			case "size": _recalcLayout();
		}
	}

	private function _layoutChange(from:Layout, to:Layout) {
		_recalcLayout();
	}

	private function _parentChange(from:NodeBase, to:NodeBase) {
		if(from != null) {
			// If parent is handling position/redraw, maybe just notify parent of child change instead of pushing an invalid rect?
			var thisRect:Rect = new Rect({ position: { x: 0, y: 0 }, size: { w: this.size.w, h: this.size.h } });
			from.redrawRects([thisRect]);
			from.removeNode(this);
			Bind.unbindAll(from);
			if(from.mouseListeners.indexOf(this) != -1) {
				from.removeMouseListener(this);
			}
		}
		
		// TODO: review assign parent vs add/removeNode - some overlap here
		to.addNode(this);
		_recalcLayout();
		if(mouseListeners.length > 0 || mouseSubscribe) {
			to.addMouseListener(this);
		}
		// TODO: maybe call parent redrawRects?
	}

	private function _recalcLayout() {
		// Prepare to adjust size
		var newSize = new Size({ w: size.w, h: size.h });

		// Rethink layout - size should just be the minimum size and parent moves child as needed based on layout rules?

		// Adjust width, fixed then percent as available
		if(layout.widthFixed != null) {
			// TODO: Unbind percent width?
			newSize.w = layout.widthFixed;
		} else if(layout.widthPercent != null) {
			if(parent != null) {
				newSize.w = parent.size.w*(layout.widthPercent/100);
			} else {
				newSize.w = 0;
			}
			// TODO: Bind percent width to parent property?
		}

		// Adjust height, fixed then percent as available
		if(layout.heightFixed != null) {
			// TODO: Unbind percent height?
			newSize.h = layout.heightFixed;
		} else if(layout.heightPercent != null) {
			if(parent != null) {
				newSize.h = parent.size.h*(layout.heightPercent/100);
			} else {
				newSize.h = 0;
			}
			// TODO: Bind percent height to parent property?
		}

		// Adjust left position, fixed then percent as available
		/*if(layout.marginLeftFixed != null) {
			newPosition.left = layout.marginLeftFixed;
		} else if(layout.marginLeftPercent != null) {
			newPosition.left = parent.size.width*(layout.marginLeftPercent/100);
		}

		// Adjust top position, fixed then percent as available
		if(layout.marginTopFixed != null) {
			newPosition.top = layout.marginTopFixed;
		} else if(layout.marginTopPercent != null) {
			newPosition.top = parent.size.height*(layout.marginTopPercent/100);
		}*/

		/*
		if(parent != null && Type.getClassName(Type.getClass(parent)) == "hxfx.layout.ScrollableContainer") {
		trace(Type.getClassName(Type.getClass(this)) + "._doLayout, parent == " + Type.getClassName(Type.getClass(parent)) + " parent.size == " + parent.size);
		
		trace(Type.getClassName(Type.getClass(this)) + "._doLayout, newSize == " + newSize);
		}
		*/
		size = newSize;

		var thisRect:Rect = new Rect({ position: { x: 0, y: 0 }, size: { w: this.size.w, h: this.size.h } });
		redrawRects([thisRect]);
	}

	private function addNode(childNode:NodeBase):Void {
		_childNodes.set(childNode, new Position({x:0, y:0}));
	}

	private function removeNode(childNode:NodeBase):Bool {
		return _childNodes.remove(childNode);
	}

	/**
	Tell render system that the portion of this node is invalid and should be redrawn
	parents may use cull value to block invalidation
	**/
	public function redrawRects(rectArray:Array<Rect>) {
		if(!cull && parent != null) {
			// TODO: translate rectangle based on child/parent positioning - how?
			parent.redrawRects(rectArray);
		}
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
		if(_childNodes.exists(child) && mouseListeners.indexOf(child) == -1) {
			if(mouseData == null) {
				mouseData = new MouseData();
			}
			Bind.bindAll(mouseData, _doMouseChanged);
			mouseListeners.push(child);
			if(parent != null) {
				parent.addMouseListener(this);
			}
		}
	}

	public function removeMouseListener(child:NodeBase) {
		mouseListeners.remove(child);
		if(mouseListeners.length == 0 && !this.mouseSubscribe) {
			Bind.unbindAll(mouseData);
		}
	}

	private function _doMouseChanged(origin:IBindable, name:String, from:Dynamic, to:Dynamic) {
		for(l in mouseListeners) {
			var childPos = _childNodes.get(l);
			l.mouseData.x = mouseData.x - childPos.x;
			l.mouseData.y = mouseData.y - childPos.y;
			l.mouseData.xd = mouseData.xd;
			l.mouseData.yd = mouseData.yd;
			l.mouseData.b1down = mouseData.b1down;
			l.mouseData.b2down = mouseData.b2down;
			l.mouseData.b3down = mouseData.b3down;
			l.mouseData.wheeld = mouseData.wheeld;
			l.mouseData.wheel = mouseData.wheel;
			l.mouseData.mouseInWindow = mouseData.mouseInWindow;
		}

		if(mouseData.x>=0 && mouseData.x<=size.w && mouseData.y>=0 && mouseData.y<=size.h) {
			mouseInBounds = true;
		} else {
			mouseInBounds = false;
		}
	}

	public function render(g2: Graphics): Void {
		// Draw myself - clear to my background color
		// TODO: this should only clear invalid rects for the area within this node
		if(backgroundColor.A > 0) {
			var _c = g2.color;
			g2.color = backgroundColor;
			g2.fillRect(0,0,size.w,size.h);
			g2.color = _c;
		}

		for(c in _childNodes.keys()) {
			// TODO: Calc redraw based on invalid rects? 
			// Pass rects down chain (with translation) and each node can choose which children to render?
			var childPos = _childNodes.get(c);
			g2.pushTranslation(childPos.x, childPos.y);
			c.render(g2);
			g2.popTransformation();
		}
	}
}