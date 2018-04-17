package hxfx.core.data;

typedef SizeDef = {
	?w:Float,
	?h:Float
}

@:bindable
class Size implements IBindable  {
	public var w:Float = 0;
	public var h:Float = 0;

	public function new(size:SizeDef) {
		if(size.w != null)
			this.w = size.w;

		if(size.h != null)
			this.h = size.h;
	}
}