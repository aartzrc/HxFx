package hxfx.layout;

import hxfx.core.NodeBase;

/**
This container does not manage any positioning, simply marks itself as dirty when resized
Add children and set position, simply passes render calls down to children
TODO: Assign border details via LayoutRule or directly to this container?
**/
@:bindable
class BorderContainer extends AbsoluteContainer {
	public var borderWidth:Float = 1;
	public var borderColor:kha.Color;

	override public function render(g2: Graphics): Void {
		super.render(g2); // What to do after super has rendered? It did all the children, but now I want to render more that could overwrite a child.. hmm

		if(borderColor != null && borderColor.A>0) {
			g2.color = borderColor;
			g2.drawRect(0,0,layoutSize.w, layoutSize.h, borderWidth);
		}
	}
}