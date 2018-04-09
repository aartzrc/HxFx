package hxfx.layout;

import hxfx.core.NodeBase;

/**
Displays and manages horizontal and vertical scroll bars based on child boundaries
**/
@:bindable
class ScrollableContainer extends NodeBase {
	
	public var childBounds:Rect = new Rect({position: {left:null, top:null}, size:{width:null, height:null}});
	public var verticalScrollbar:Bool = false;
	public var horizontalScrollbar:Bool = false;

	public function new() {
		super();
		Bind.bind(this.childBounds, _boundsChanged);
	}

	private function _boundsChanged(from:Rect, to:Rect) {
		_calculateScrollbars();
	}

	private function _calculateScrollbars() {
		verticalScrollbar = false;
		horizontalScrollbar = false;
		if(childBounds.size.width != null) {
			if(childBounds.size.width>this.size.width)
				horizontalScrollbar = true;
		}
		if(childBounds.size.height != null) {
			if(childBounds.size.height>this.size.height)
				verticalScrollbar = true;
		}
	}

	override private function addNode(childNode:NodeBase):Void {
		super.addNode(childNode);
		Bind.bind(childNode.size, _childSizeChanged);
		Bind.bind(childNode.relativePosition, _childPositionChanged);
	}

	override private function removeNode(childNode:NodeBase):Bool {
		if(super.removeNode(childNode)) {
			_calcChildBounds();
			return true;
		}
		return false;
	}

	private function _childSizeChanged(from:Size, to:Size) {
		_calcChildBounds();
	}

	private function _childPositionChanged(from:Position, to:Position) {
		_calcChildBounds();
	}

	private function _calcChildBounds() {
		// Determine child bounds
		var newChildBounds = new Rect({position: {left:null, top:null}, size:{width:null, height:null}});
		for(c in _childNodes) {
			if(newChildBounds.position.left == null) {
				newChildBounds.position.left = c.relativePosition.left;
			} else {
				if(c.relativePosition.left < newChildBounds.position.left)
					newChildBounds.position.left = c.relativePosition.left;
			}
			if(newChildBounds.position.top == null) {
				newChildBounds.position.top = c.relativePosition.top;
			} else {
				if(c.relativePosition.top < newChildBounds.position.top)
					newChildBounds.position.top = c.relativePosition.top;
			}
			if(newChildBounds.size.width == null) {
				newChildBounds.size.width = c.relativePosition.left+c.size.width;
			} else {
				if(newChildBounds.size.width < c.relativePosition.left+c.size.width)
					newChildBounds.size.width = c.relativePosition.left+c.size.width;
			}
			if(newChildBounds.size.height == null) {
				newChildBounds.size.height = c.relativePosition.top+c.size.height;
			} else {
				if(newChildBounds.size.height < c.relativePosition.top+c.size.height)
					newChildBounds.size.height = c.relativePosition.top+c.size.height;
			}
			/*trace("this child:");
			trace(c.relativePosition);
			trace(c.size);*/
		}

		//trace("final: " + newChildBounds);

		childBounds = newChildBounds;
	}

	override public function render(g2: Graphics): Void {
		super.render(g2);

		// TODO: make scroll bars their own node, the should be part of a grid layout system that gets built by the scrollablecontainer
		// Draw scroll bars
		var _c = g2.color;
		if(verticalScrollbar) {
			g2.color = Color.Black;
			g2.drawRect(size.width - 15, 0, 15, size.height);
		}
		if(horizontalScrollbar) {
			g2.color = Color.Black;
			g2.drawRect(0, size.height-15, size.width, size.height);
		}
		g2.color = _c;
	}

}