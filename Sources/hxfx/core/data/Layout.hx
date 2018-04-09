package hxfx.core.data;

@:bindable
class Layout implements IBindable  {
	public var widthPercent: Float;
	public var heightPercent: Float;
	public var marginLeftPercent: Float;
	public var marginRightPercent: Float;
	public var marginTopPercent: Float;
	public var marginBottomPercent: Float;

	public var widthFixed: Float;
	public var heightFixed: Float;
	public var marginLeftFixed: Float;
	public var marginRightFixed: Float;
	public var marginTopFixed: Float;
	public var marginBottomFixed: Float;

	public var alignWidth: Float;
	public var aligneHeight: Float;

	public function new() {
	}
}