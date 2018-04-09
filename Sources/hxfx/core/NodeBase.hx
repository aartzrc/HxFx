package hxfx.core;

/**
Root level class for a Display Node
Add/remove child nodes
All children will receive messages?
All children will get render call?
**/
@:bindable
class NodeBase implements IBindable  {
	// Stores the current width and height - this will be adjusted based on NodeLayout input and should be read only
	public var size:Size;
	public var cull:Bool; // Use for render culling, render updates won't be passed through

	public var layout:Layout;
	public var backgroundColor:Color = Color.White;

	private var _childNodes:Array<NodeBase> = [];
	public var parent:NodeBase;
	// Should each child track its position within the parent? or should the parent be in charge of this?
	public var relativePosition:Position = new Position({top:0, left:0});

	/* note, empty constructor was chosen so that instances could be initialized before parent was assigned
	assigning parent causes a full invalid rect to be pushed, set all initial values before assigning parent to avoid invalid rect duplication
	*/
	public function new() {
		size = new Size({});
		layout = new Layout();
		Bind.bind(this.layout, doLayoutChange);
		Bind.bind(this.parent, doParentChange);
	}

	private function doParentPropertyChange(name: String, from:Dynamic, to:Dynamic) {
		switch(name) {
			case "size": _doLayout();
		}
	}

	private function doLayoutChange(from:Layout, to:Layout) {
		_doLayout();
	}

	private function doParentChange(from:NodeBase, to:NodeBase) {
		if(from != null) {
			var thisRect:Rect = new Rect({ position: { left: 0, top: 0 }, size: { width: this.size.width, height: this.size.height } });
			from.redrawRects([thisRect]);
			from.removeNode(this);
			Bind.unbindAll(from);
		}
		
		// TODO: review assign parent vs add/removeNode - some overlap here
		to.addNode(this);
		Bind.bindAll(to, doParentPropertyChange);
		_doLayout();
		// TODO: maybe call parent redrawRects?
	}

	private function _doLayout() {
		// Prepare to adjust size
		var newSize = new Size({ width: size.width, height: size.height });
		var newPosition = new Position({ top: 0, left: 0});

		// Adjust width, fixed then percent as available
		if(layout.widthFixed != null) {
			// TODO: Unbind percent width?
			newSize.width = layout.widthFixed;
		} else if(layout.widthPercent != null) {
			if(parent != null) {
				newSize.width = parent.size.width*(layout.widthPercent/100);
			} else {
				newSize.width = 0;
			}
			// TODO: Bind percent width to parent property?
		}

		// Adjust height, fixed then percent as available
		if(layout.heightFixed != null) {
			// TODO: Unbind percent height?
			newSize.height = layout.heightFixed;
		} else if(layout.heightPercent != null) {
			if(parent != null) {
				newSize.height = parent.size.height*(layout.heightPercent/100);
			} else {
				newSize.height = 0;
			}
			// TODO: Bind percent height to parent property?
		}

		// Adjust left position, fixed then percent as available
		if(layout.marginLeftFixed != null) {
			newPosition.left = layout.marginLeftFixed;
		} else if(layout.marginLeftPercent != null) {
			newPosition.left = parent.size.width*(layout.marginLeftPercent/100);
		}

		// Adjust top position, fixed then percent as available
		if(layout.marginTopFixed != null) {
			newPosition.top = layout.marginTopFixed;
		} else if(layout.marginTopPercent != null) {
			newPosition.top = parent.size.height*(layout.marginTopPercent/100);
		}

		/*
		if(parent != null && Type.getClassName(Type.getClass(parent)) == "hxfx.layout.ScrollableContainer") {
		trace(Type.getClassName(Type.getClass(this)) + "._doLayout, parent == " + Type.getClassName(Type.getClass(parent)) + " parent.size == " + parent.size);
		
		trace(Type.getClassName(Type.getClass(this)) + "._doLayout, newSize == " + newSize);
		}
		*/

		size = newSize;
		relativePosition = newPosition;

		var thisRect:Rect = new Rect({ position: { left: relativePosition.left, top: relativePosition.top }, size: { width: this.size.width, height: this.size.height } });
		redrawRects([thisRect]);
	}

	private function addNode(childNode:NodeBase):Void {
		_childNodes.push(childNode);
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

	public function render(g2: Graphics): Void {
		// Draw myself - clear to my background color
		// TODO: this should only clear invalid rects for the area within this node
		if(backgroundColor.A > 0) {
			var _c = g2.color;
			g2.color = backgroundColor;
			g2.fillRect(0,0,size.width,size.height);
			g2.color = _c;
		}

		for(c in _childNodes) {
			// TODO: Calc redraw based on invalid rects? 
			// Pass rects down chain (with translation) and each node can choose which children to render?
			g2.pushTranslation(c.relativePosition.left, c.relativePosition.top);
			c.render(g2);
			g2.popTransformation();
		}
	}
}