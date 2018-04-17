package hxfx.core.data;

typedef PositionDef = {
	?x:Float,
	?y:Float
}

@:bindable
class Position implements IBindable  {
	public var x:Float = 0;
	public var y:Float = 0;

	public function new(position:PositionDef) {
		if(position.x != null)
			this.x = position.x;

		if(position.y != null)
			this.y = position.y;
	}
}