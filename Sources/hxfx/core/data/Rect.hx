package hxfx.core.data;

import hxfx.core.data.Position;
import hxfx.core.data.Size;

typedef RectDef = {
	?position:PositionDef,
	?size:SizeDef
}

@:bindable
class Rect implements IBindable  {
	public var position:Position;
	public var size:Size;

	public function new(rect:RectDef) {
		position = new Position(rect.position);
		size = new Size(rect.size);
	}

	public function inBounds(loc:Position) {
		var xRelative = loc.x - position.x;
		var yRelative = loc.y - position.y;
		return (xRelative >= 0 && xRelative <= size.w && yRelative >= 0 && yRelative <= size.h);
	}
}