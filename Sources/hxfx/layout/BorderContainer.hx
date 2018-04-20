package hxfx.layout;

import hxfx.core.NodeBase;

/**
Wrap a child in a border - if child is larger than container, the container will resize to match
TODO: Assign border details via LayoutRule or directly to this container?
**/
@:bindable
class BorderContainer extends AbsoluteContainer {
	public var borderWidth:Float = 1;
	public var borderColor:kha.Color;

	public static override function calcSize(node:BorderContainer, layoutSize:Size) {
		var newSize = NodeBase.calcSize(node, layoutSize);

		// Check all children sizes
		for(child in node._childNodes) {
			child.layoutToSize(new Size({w:node.size.w, h:node.size.h}));

			// This should take in to account child positioning/etc, for now just use the child size...
			if(child.size.w > newSize.w) newSize.w = child.size.w;
			if(child.size.h > newSize.h) newSize.h = child.size.h;
		}

		return newSize;
	}

	private override function _calcSize(layoutSize:Size) {
		return calcSize(this, layoutSize);
	}

	override public function render(g2: Graphics): Void {
		super.render(g2); // What to do after super has rendered? It did all the children, but now I want to render more that could overwrite a child.. hmm

		if(borderColor != null && borderColor.A>0) {
			g2.color = borderColor;
			g2.drawRect(0,0,size.w, size.h, borderWidth);
		}
	}
}