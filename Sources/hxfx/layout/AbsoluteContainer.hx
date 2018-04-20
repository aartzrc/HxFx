package hxfx.layout;

import hxfx.core.NodeBase;

/**
This container does not manage any positioning, simply marks itself as dirty when resized
Add children and set position, simply passes render calls down to children
**/
@:bindable
class AbsoluteContainer extends NodeBase {
	// Should an AbsoluteContainer have a lower limit size based on children?
}