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
}