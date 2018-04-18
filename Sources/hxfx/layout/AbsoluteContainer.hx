package hxfx.layout;

import hxfx.core.NodeBase;

/**
This container does not manage any positioning, simply marks itself as dirty when resized
Add children and set position, simply passes render calls down to children
**/
@:bindable
class AbsoluteContainer extends NodeBase {
	public override function layoutToSize(size:Size):Bool {
		if(super.layoutToSize(size)) {
			addRedrawRect(new Rect({position: {x:0, y:0}, size: {w:layoutSize.w, h:layoutSize.h}}));
			redrawRequested = true;
			return true;
		}

		return false;
	}
}