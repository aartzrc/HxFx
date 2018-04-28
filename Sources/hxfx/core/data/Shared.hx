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
class Rect extends BoundsShape implements IBindable  {
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

	override public function inBounds(loc:Position) {
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

	override function get_clone():BoundsShape {
		return new Rect({position: {x: position.x, y: position.y}, size: {w:size.w, h:size.h}});
	}
}

typedef CircleDef = {
	?position:PositionDef,
	?radius:Float
}

@:bindable
class Circle extends BoundsShape implements IBindable  {
	public var radius:Float = 0;

	public function new(?circle:CircleDef) {
		if(circle != null) {
			if(circle.position != null) {
				position = new Position(circle.position);
			} else {
				position = new Position();
			}
			if(circle.radius != null)
				radius = circle.radius;
		} else {
			position = new Position();
		}
	}

	override public function inBounds(loc:Position) {
		var x = loc.x - position.x;
		var y = loc.y - position.y;
		var dist = Math.sqrt(x*x + y*y);
		return (dist<radius);
	}

	override function get_clone():BoundsShape {
		return new Circle({position: {x: position.x, y: position.y}, radius: radius});
	}
}

class BoundsShape {
	public var position:Position;

	public function inBounds(loc:Position):Bool {
		throw "inBounds not implemented";
	}

	public var clone(get, never):BoundsShape;

	function get_clone():BoundsShape {
		throw "clone not implemented";
	}

	/**
	 *  Create a new instance of this BoundsShape with the position translated by the offset amount
	 *  @param offset - 
	 *  @return BoundsShape
	 */
	public function translate(offset:Position):BoundsShape {
		var c = this.clone;
		c.position.x+=offset.x;
		c.position.y+=offset.y;
		return c;
	}
}

class HitBounds {
	public var bounds:Array<BoundsShape> = new Array<BoundsShape>();

	public function new() {}

	public function inBounds(loc:Position, ?scissorSize:Size):Bool {
		if(scissorSize != null) {
			if(loc.x > scissorSize.w || loc.y>scissorSize.h) return false;
		}
		
		for(b in bounds) {
			if(b.inBounds(loc)) return true;
		}

		return false;
	}
}