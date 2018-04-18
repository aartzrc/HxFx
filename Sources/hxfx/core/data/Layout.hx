package hxfx.core.data;

/** 
Use 'standard' 12pt, 16px, 1em, 100% size concept at 96dpi - for example: https://websemantics.uk/articles/font-size-conversion/
All font sizes are based on this, font size is float - 1.0 == 1em size
Width/height sizes are same, 1.0 float == 16px
**/

typedef ChildNode = {
	child:NodeBase,
	rect:Rect
}

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
	public var alignHeight: Float;

	public function new() {
	}
}