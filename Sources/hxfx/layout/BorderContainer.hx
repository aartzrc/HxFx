package hxfx.layout;

import hxfx.core.NodeBase;
import hxfx.display.*;
import hxfx.display.BorderEdge.Edge;

/*
Borderlayout is a bit tricky when corner radii are added. It is nice to start with a 3x3 grid and draw the edges using the cells, 
but then edges have to be smart enough to fill the space between the outside edge and the viewport when the radius is larger than the border width.
Also, all edges should bind to the width and radius properties so that they update without a fight
 */

@:bindable
class BorderContainer extends GridContainer {

	var left:BorderEdge;
	var right:BorderEdge;
	var top:BorderEdge;
	var bottom:BorderEdge;

	public function new() {
		super(3,3); // Create a 3x3 grid

		left = new BorderEdge(this, Left);
		left.parent = getCell(0,1);
		right = new BorderEdge(this, Right);
		right.parent = getCell(2,1);
		top = new BorderEdge(this, Top);
		top.parent = getCell(1,0);
		bottom = new BorderEdge(this, Bottom);
		bottom.parent = getCell(1,2);

		Bind.bind(this.borderColor, _doColorChanged);

		// Default to showing no border
		setBorderRule(Width(0));

		setChildIndex(viewport, _childNodes.length-1); // Make the viewport render last
	}

	public var viewport(get, never):NodeBase;

	function get_viewport() {
		return getCell(1,1);
	}

	function _doColorChanged(from:Color, to:Color) {
		// Pass the color to borders
		left.settings.color = to;
		right.settings.color = to;
		top.settings.color = to;
		bottom.settings.color = to;
	}

	public function setBorderRule(newRule:BorderRule) {
		switch(newRule) {
			case Width(w):
				borderWidth = w;
/*
				
				// Set the top row to w tall and fixed to top
				setRowLayoutRule(0, Height(LayoutSize.Fixed(w)));
				setRowLayoutRule(0, BaseRule.AlignY(Align.PercentLT(0)));

				// Set the bottom row to w tall and fixed to bottom
				setRowLayoutRule(2, Height(LayoutSize.Fixed(w)));
				setRowLayoutRule(2, BaseRule.AlignY(Align.PercentRB(100)));

				// Set the left column to w width and fixed to left
				setColumnLayoutRule(0, Width(LayoutSize.Fixed(w)));
				setColumnLayoutRule(0, BaseRule.AlignX(Align.PercentLT(0)));

				// Set the right column to w width and fixed to right
				setColumnLayoutRule(2, Width(LayoutSize.Fixed(w)));
				setColumnLayoutRule(2, BaseRule.AlignX(Align.PercentRB(100)));

				// Set the middle row to fill the remaining space
				setRowLayoutRule(1, Height(LayoutSize.PercentLessFixed(100, w*2)));
				setRowLayoutRule(1, BaseRule.AlignY(Align.PercentM(50)));

				// Set the middle column to fill the remaining space
				setColumnLayoutRule(1, Width(LayoutSize.PercentLessFixed(100, w*2)));
				setColumnLayoutRule(1, BaseRule.AlignX(Align.PercentM(50)));
			case Color(c):
				// Set the color for all the outside cells
				borderColor = c;
			case CornerRadius(r):
				_cornerRadius = r;

				// Swap in arcs for corners
				var tl = new ArcQuadrant();
				tl.setLayoutRule(BackgroundColor(backgroundColor));
				tl.setLayoutRule(Color(borderColor));
				tl.setArcRule(Width(width));
				tl.setArcRule(Radius(r));

				var tlCell = getCell(0,0); // Top left
				tlCell.clearChildren();
				tlCell.setLayoutRule(BackgroundColor(kha.Color.Transparent));
				tl.parent = tlCell; // Corner handles background and arc

				getCell(0,1).setLayoutRule(Height(LayoutSize.PercentLessFixed(100, r*2)));
				getCell(2,1).setLayoutRule(Height(LayoutSize.PercentLessFixed(100, r*2)));

				viewport.setLayoutRule(Width(LayoutSize.PercentLessFixed(100, _cornerRadius)));
				viewport.setLayoutRule(Height(LayoutSize.PercentLessFixed(100, _cornerRadius)));
				viewport.setLayoutRule(BackgroundColor(kha.Color.Red));*/
			case _:
				// Ignore
		}
	}

	override public function render(g2: Graphics): Void {
		// Override super to block full background draw
		// Let the cells do the drawing

		_renderChildren(g2);
	}

	@:bindable
	public var borderWidth:Float = 0;
	@:bindable
	public var cornerRadius:Float = 0;
	@:bindable
	public var borderColor:kha.Color = kha.Color.Transparent;
}

enum BorderRule {
	Width(w:Float); // TODO: left/top/right/bottom overrides?
	Color(c:kha.Color);
	CornerRadius(r:Float);
}