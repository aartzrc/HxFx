package hxfx.layout;

import hxfx.core.NodeBase;

/**
This container does not manage any positioning
Add children and set position, simply passes render calls down to children
**/
@:bindable
class AbsoluteContainer extends NodeBase {
	// Should an AbsoluteContainer default to settings.fitToChildren = true?

	override function _thisHitBounds() {
		// Add a rectangle by default
		_hitBoundsCache.bounds.push(new Rect({position: {x:0, y:0}, size: {w:size.w, h:size.h}}));
	}

}