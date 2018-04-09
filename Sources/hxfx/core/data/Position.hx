package hxfx.core.data;

typedef PositionDef = {
	?left:Float,
	?top:Float
}

@:bindable
class Position implements IBindable  {
	public var left:Float = 0;
	public var top:Float = 0;

	public function new(position:PositionDef) {
		if(position.left != null)
			this.left = position.left;

		if(position.top != null)
			this.top = position.top;
	}
}