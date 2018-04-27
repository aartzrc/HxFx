package hxfx.core.data;

typedef PositionDef = {
	?x:Float,
	?y:Float
}

@:bindable
class Position implements IBindable  {
	public var x:Float = 0;
	public var y:Float = 0;

	public function new(?position:PositionDef) {
		if(position != null) {
			if(position.x != null)
				this.x = position.x;

			if(position.y != null)
				this.y = position.y;
		}
	}
}

typedef SizeDef = {
	?w:Float,
	?h:Float
}

@:bindable
class Size implements IBindable  {
	public var w:Float = 0;
	public var h:Float = 0;

	public function new(?size:SizeDef) {
		if(size != null) {
			if(size.w != null)
				this.w = size.w;

			if(size.h != null)
				this.h = size.h;
		}
	}
}

typedef RectDef = {
	?position:PositionDef,
	?size:SizeDef
}

@:bindable
class Rect implements IBindable  {
	public var position:Position;
	public var size:Size;

	public function new(?rect:RectDef) {
		if(rect != null) {
			position = new Position(rect.position);
			size = new Size(rect.size);
		} else {
			position = new Position();
			size = new Size();
		}
	}

	public function inBounds(loc:Position) {
		var xRelative = loc.x - position.x;
		var yRelative = loc.y - position.y;
		return (xRelative >= 0 && xRelative <= size.w && yRelative >= 0 && yRelative <= size.h);
	}

	/**
	Determine the relative location within the bounding rectangle - in float %
	0 = far left/top, 1 = far right/bottom
	**/
	public function inBoundsRelative(loc:Position) {
		var relativePos = new Position();
		var xRelative = loc.x - position.x;
		var yRelative = loc.y - position.y;
		relativePos.x = xRelative/size.w;
		relativePos.y = yRelative/size.h;

		return relativePos;
	}
}