package hxfx.core.data;

typedef SizeDef = {
	?width:Float,
	?height:Float
}

@:bindable
class Size implements IBindable  {
	public var width:Float = 0;
	public var height:Float = 0;

	public function new(size:SizeDef) {
		if(size.width != null)
			this.width = size.width;

		if(size.height != null)
			this.height = size.height;
	}
}