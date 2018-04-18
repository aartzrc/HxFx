package hxfx.core.data;

@:bindable
class MouseData implements IBindable  {
	public var x:Float = 0;
	public var xd:Float = 0;
	public var y:Float = 0;
	public var yd:Float = 0;
	public var b1down:Bool = false;
	public var b2down:Bool = false;
	public var b3down:Bool = false;
	public var wheeld:Int = 0;
	public var wheel:Int = 0;
	public var mouseInBounds:Bool = false;

	public function new() {}
}