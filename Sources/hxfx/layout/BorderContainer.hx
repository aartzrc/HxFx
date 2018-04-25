package hxfx.layout;

import hxfx.core.NodeBase;

using kha.graphics2.GraphicsExtension;

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

	var cornerLT:BorderCorner;
	var cornerRT:BorderCorner;
	var cornerRB:BorderCorner;
	var cornerLB:BorderCorner;

	public var dragFocus:NodeBase;

	public function new() {
		super(3,3, new BorderContainerSettings()); // Create a 3x3 grid with default settings

		left = new BorderEdge(this, Left);
		right = new BorderEdge(this, Right);
		top = new BorderEdge(this, Top);
		bottom = new BorderEdge(this, Bottom);

		cornerLT = new BorderCorner(this, LT);
		cornerRT = new BorderCorner(this, RT);
		cornerRB = new BorderCorner(this, RB);
		cornerLB = new BorderCorner(this, LB);
		
		setChildIndex(viewport, _childNodes.length-1); // Make the viewport render last
		viewport.settings.alignX = PercentM(50);
		viewport.settings.alignY = PercentM(50);

		Bind.bind(borderContainerSettings.bgColor, setBGColor);
	}

	public var viewport(get, never):NodeBase;

	function get_viewport() {
		return getCell(1,1);
	}

	public var borderContainerSettings(get,never):BorderContainerSettings;

	public function get_borderContainerSettings() {
		return cast settings;
	}

	function setBGColor(from:kha.Color, to:kha.Color) {
		viewport.settings.bgColor = to;
	}

	public function updateBorders() {
		// Recalc all borders

		// How much extra edges should have to work with a rounded corner
		var cornerSize = cornerLT.cornerSize;
		var viewportOffset = cornerLT.viewportOffset;

		top.parent.settings.width = PercentLessFixed(100, cornerSize*2);
		top.parent.settings.height = Fixed(viewportOffset);
		bottom.parent.settings.width = PercentLessFixed(100, cornerSize*2);
		bottom.parent.settings.height = Fixed(viewportOffset);
		left.parent.settings.height = PercentLessFixed(100, cornerSize*2);
		left.parent.settings.width = Fixed(viewportOffset);
		right.parent.settings.height = PercentLessFixed(100, cornerSize*2);
		right.parent.settings.width = Fixed(viewportOffset);

		viewport.settings.width = PercentLessFixed(100, viewportOffset*2);
		viewport.settings.height = PercentLessFixed(100, viewportOffset*2);
    }

	override public function render(g2: Graphics): Void {
		// Override super to block full background draw
		// Let the cells do the drawing

		_renderChildren(g2);
	}
}

@:bindable
class BorderContainerSettings extends NodeBaseSettings implements IBindable {
	public var borderWidth:Float = 1;
	public var borderColor:kha.Color = kha.Color.Transparent;
	public var borderCornerRadius:Float = 0;
	public var resizeable:Bool = false;
}

@:bindable
class BorderEdge extends NodeBase {
    public var edge:Edge = Edge.Top;
	public var container:BorderContainer;

	var border:AbsoluteContainer = new AbsoluteContainer();
	var fill:AbsoluteContainer = new AbsoluteContainer();

	public function new(container:BorderContainer, edge:Edge) {
		super();
        this.edge = edge;
		this.container = container;

		_init();
		
		Bind.bind(container.borderContainerSettings.borderWidth, setBorderWidth);
		Bind.bind(container.borderContainerSettings.borderColor, setBorderColor);
		Bind.bind(container.borderContainerSettings.bgColor, setBGColor);
		Bind.bind(container.borderContainerSettings.resizeable, setResizable);
	}

	function _init() {
		switch(edge) {
			case Top:
				// 100% width, border sticks to top, fill sticks to bottom
				border.settings.width = Percent(100);
				border.settings.alignY = PercentLT(0);
				fill.settings.width = Percent(100);
				fill.settings.alignY = PercentRB(100);

				// Top edge, so stick myself to the top and fill 100% width of cell
				settings.width = Percent(100);
				settings.height = Percent(100);
				settings.alignY = PercentLT(0);

				// Attach to the top middle
				parent = container.getCell(1,0);

				// Tell my parent to stay in the middle top
				parent.settings.alignX = PercentM(50);
				parent.settings.alignY = PercentLT(0);
			case Bottom:
				// 100% width, border sticks to bottom, fill sticks to top
				border.settings.width = Percent(100);
				border.settings.alignY = PercentRB(100);
				fill.settings.width = Percent(100);
				fill.settings.alignY = PercentLT(0);

				// Bottom edge, so stick myself to the bottom and fill 100% width of cell
				settings.width = Percent(100);
				settings.height = Percent(100);
				settings.alignY = PercentRB(100);

				// Attach to the bottom middle
				parent = container.getCell(1,2);

				// Tell my parent to stay in the middle bottom
				parent.settings.alignX = PercentM(50);
				parent.settings.alignY = PercentRB(100);
			case Right:
				// 100% height, border sticks to right, fill sticks to left
				border.settings.height = Percent(100);
				border.settings.alignX = PercentRB(100);
				fill.settings.height = Percent(100);
				fill.settings.alignX = PercentLT(0);

				// Right edge, so stick myself to the right and fill 100% height of cell
				settings.width = Percent(100);
				settings.height = Percent(100);
				settings.alignX = PercentRB(100);

				// Attach to the right middle
				parent = container.getCell(2,1);

				// Tell my parent to stay in the middle
				parent.settings.alignY = PercentM(50);
				parent.settings.alignX = PercentRB(100);
			case Left:
				// 100% height, border sticks to left, fill sticks to right
				border.settings.height = Percent(100);
				border.settings.alignX = PercentLT(0);
				fill.settings.height = Percent(100);
				fill.settings.alignX = PercentRB(100);

				// Left edge, so stick myself to the left and fill 100% height of cell
				settings.width = Percent(100);
				settings.height = Percent(100);
				settings.alignX = PercentLT(0);

				// Attach to the right middle
				parent = container.getCell(0,1);

				// Tell my parent to stay in the middle
				parent.settings.alignY = PercentM(50);
				parent.settings.alignX = PercentLT(0);
		}
		
		border.parent = this;
		fill.parent = this;
	}

    function setBorderWidth(from:Float, to:Float) {
		switch(edge) {
			case Top, Bottom:
				border.settings.height = Fixed(to);
				fill.settings.height = PercentLessFixed(100, to);
			case Left, Right:
				border.settings.width = Fixed(to);
				fill.settings.width = PercentLessFixed(100, to);
		}
    }

	function setBorderColor(from:Color, to:Color) {
		border.settings.bgColor = to;
    }

	function setBGColor(from:Color, to:Color) {
		fill.settings.bgColor = to;
    }

	function setResizable(from:Bool, to:Bool) {
		if(!to) {
			settings.cursor = null;
			Bind.unbind(mouseData.b1down, mouseDown);
			return;
		}
		switch(edge) {
			case Left, Top:
				// No resize cursor
			case Right:
				settings.cursor = "e-resize";
				Bind.bind(mouseData.b1down, mouseDown);
			case Bottom:
				settings.cursor = "s-resize";
				Bind.bind(mouseData.b1down, mouseDown);
		}
	}

	function mouseDown(from:Bool, to:Bool) {
		if(to && mouseData.mouseInBounds) {
			if(container.dragFocus == null) {
				container.dragFocus = this;
				switch(edge) {
					case Left, Top:
						// No resize?
					case Right:
						container.settings.width = Fixed(container.size.w);
						Bind.bind(container.mouseData.x, mouseDrag);
					case Bottom:
						container.settings.height = Fixed(container.size.h);
						Bind.bind(container.mouseData.y, mouseDrag);
				}
			}
		} else {
			container.dragFocus = null;
			Bind.unbind(container.mouseData.x, mouseDrag);
			Bind.unbind(container.mouseData.y, mouseDrag);
		}
	}

	function mouseDrag(from:Float, to:Float) {
		switch(edge) {
			case Left, Top:
				// No resize?
			case Right:
				container.settings.width = Fixed(container.mouseData.x);
			case Bottom:
				container.settings.height = Fixed(container.mouseData.y);
		}
	}
}

enum Edge {
	Left;
	Right;
	Top;
	Bottom;
}

@:bindable
class BorderCorner extends NodeBase {
    public var corner:Corner = Corner.LT;
	public var container:BorderContainer;

	public function new(container:BorderContainer, corner:Corner) {
		super();
        this.corner = corner;
		this.container = container;

		_init();
		
		Bind.bind(container.borderContainerSettings.borderWidth, setWidthOrRadius);
		Bind.bind(container.borderContainerSettings.borderColor, setBorderColor);
		Bind.bind(container.borderContainerSettings.borderCornerRadius, setWidthOrRadius);
		Bind.bind(container.borderContainerSettings.resizeable, setResizable);
	}

	function _init() {
		// Fill the corner
		settings.width = Percent(100);
		settings.height = Percent(100);

		switch(corner) {
			case LT:
				parent = container.getCell(0,0);
				// Stick to left/top
				parent.settings.alignX = PercentLT(0);
				parent.settings.alignY = PercentLT(0);
			case RT:
				parent = container.getCell(2,0);
				// Stick to right/top
				parent.settings.alignX = PercentRB(100);
				parent.settings.alignY = PercentLT(0);
			case RB:
				parent = container.getCell(2,2);
				// Stick to right/bottom
				parent.settings.alignX = PercentRB(100);
				parent.settings.alignY = PercentRB(100);
				settings.cursor = "se-resize";
			case LB:
				parent = container.getCell(0,2);
				// Stick to left/bottom
				parent.settings.alignX = PercentLT(0);
				parent.settings.alignY = PercentRB(100);
		}
	}

	function setResizable(from:Bool, to:Bool) {
		if(!to) {
			settings.cursor = null;
			return;
		}
		switch(corner) {
			case LT, RT, LB:
				// No resize cursor
			case RB:
				settings.cursor = "nwse-resize";
				Bind.bind(mouseData.b1down, mouseDown);
		}
	}

	function setWidthOrRadius(from:Float, to:Float) {
		parent.settings.width = Fixed(cornerSize);
		parent.settings.height = Fixed(cornerSize);

		container.updateBorders();
    }

	function setBorderColor(from:Color, to:Color) {
		settings.bgColor = to;
    }

	public var cornerSize(get, never):Float;

	function get_cornerSize() {
		var s = container.borderContainerSettings;
		var d = s.borderWidth;
		// Calculate for rounded corners
		if(s.borderCornerRadius > s.borderWidth) {
			d = s.borderCornerRadius;
		}
		return d;
	}

	public var viewportOffset(get, never):Float;

	function get_viewportOffset() {
		var s = container.borderContainerSettings;
		var insideRadius = s.borderCornerRadius-s.borderWidth;
		//var insideRadius = s.borderCornerRadius;
		if(insideRadius<0) return s.borderWidth;
		return cornerSize - (insideRadius*.6); // Technically sqrt(1/2r) to get sin @ 45deg - approx .7, leave margin with .6
	}

	function mouseDown(from:Bool, to:Bool) {
		if(to && mouseData.mouseInBounds) {
			if(container.dragFocus == null) {
				container.dragFocus = this;
				switch(corner) {
					case LT, RT, LB:
						// No resize?
					case RB:
						container.settings.height = Fixed(container.size.h);
						container.settings.width = Fixed(container.size.w);
						Bind.bind(container.mouseData.y, mouseDrag);
						Bind.bind(container.mouseData.x, mouseDrag);
				}
			}
		} else {
			container.dragFocus = null;
			Bind.unbind(container.mouseData.x, mouseDrag);
			Bind.unbind(container.mouseData.y, mouseDrag);
		}
	}

	function mouseDrag(from:Float, to:Float) {
		switch(corner) {
			case LT, RT, LB:
				// No resize?
			case RB:
				container.settings.height = Fixed(container.mouseData.y);
				container.settings.width = Fixed(container.mouseData.x);
		}
	}

	override public function render(g2: Graphics): Void {
		if(container.borderContainerSettings.borderCornerRadius <= 0) {
			// Just draw a rectangle
			super.render(g2);
		} else {
			// Override super to block full background draw
			var bw = container.borderContainerSettings.borderWidth;
			var cr = container.borderContainerSettings.borderCornerRadius;
			if(bw<cr) { // Border is less than radius, draw 'stroked' arc
				// Draw the arc
				if(container.borderContainerSettings.borderColor.A > 0) {
					g2.color = container.borderContainerSettings.borderColor;
					
					// drawArc with width does not fully fill - not sure if this is Kha or underlying WebGL problem
					// workaround is to do a fillArc and take a bite out of it - this will not work with a transparent background!
					switch(corner) {
						case LT:
							//g2.drawArc(size.w,size.h,cr-(bw/2),Math.PI,Math.PI*1.5,bw); 
							g2.fillArc(cr,cr,cr,Math.PI,Math.PI*1.5);
							g2.fillTriangle(0,cr,cr,cr,cr,0);
							g2.fillRect(0,cr,size.w,size.h-cr);
							g2.fillRect(cr,0,size.w-cr,cr);
						case RT:
							//g2.drawArc(0,size.h,cr-(bw/2),Math.PI*1.5,Math.PI*2,bw);
							g2.fillArc(size.w-cr,cr,cr,Math.PI*1.5,Math.PI*2);
							g2.fillTriangle(size.w-cr,0,size.w-cr,cr,size.w,cr);
							g2.fillRect(0,0,size.w-cr,size.h);
							g2.fillRect(size.w-cr,cr,cr,size.h-cr);
						case RB:
							//g2.drawArc(0,0,cr-(bw/2),Math.PI*2,Math.PI*.5,bw);
							g2.fillArc(size.w-cr,size.h-cr,cr,Math.PI*2,Math.PI*.5);
							g2.fillTriangle(size.w,size.h-cr,size.w-cr,size.h-cr,size.w-cr,size.h);
							g2.fillRect(0,0,size.w,size.h-cr);
							g2.fillRect(0,size.h-cr,size.w-cr,cr);
						case LB:
							//g2.drawArc(size.w,0,cr-(bw/2),Math.PI*.5,Math.PI,bw);
							g2.fillArc(cr,size.h-cr,cr,Math.PI*.5,Math.PI);
							g2.fillTriangle(0,size.h-cr,cr,size.h-cr,cr,size.h);
							g2.fillRect(0,0,size.w,size.h-cr);
							g2.fillRect(cr,size.h-cr,size.w-cr,cr);
					}
				}

				// Fill background
				if(container.settings.bgColor.A > 0) {
					g2.color = container.settings.bgColor;
					
					switch(corner) {
						case LT:
							g2.fillArc(size.w,size.h,cr - bw,Math.PI,Math.PI*1.5);
							g2.fillTriangle(bw,size.h,size.w,size.h,size.w,bw);
						case RT:
							g2.fillArc(0,size.h,cr - bw,Math.PI*1.5,Math.PI*2);
							g2.fillTriangle(0,size.h,size.w-bw,size.h,0,bw);
						case RB:
							g2.fillArc(0,0,cr - bw,Math.PI*2,Math.PI*.5);
							g2.fillTriangle(0,0,size.w-bw,0,0,size.h-bw);
						case LB:
							g2.fillArc(size.w,0,cr - bw,Math.PI*.5,Math.PI);
							g2.fillTriangle(size.w,0,size.w,size.h-bw,bw,0);
					}
				}
			} else {
				var bw = container.borderContainerSettings.borderWidth;
				var cr = container.borderContainerSettings.borderCornerRadius;

				// Corner is less than border radius, draw a filled corner
				if(container.borderContainerSettings.borderColor.A > 0) {
					g2.color = container.borderContainerSettings.borderColor;
					
					switch(corner) {
						case LT:
							g2.fillArc(cr,cr,cr,Math.PI,Math.PI*1.5);
							g2.fillTriangle(0,cr,cr,cr,cr,0);
							g2.fillRect(0,cr,size.w,size.h-cr);
							g2.fillRect(cr,0,size.w-cr,cr);
						case RT:
							g2.fillArc(size.w-cr,cr,cr,Math.PI*1.5,Math.PI*2);
							g2.fillTriangle(size.w-cr,0,size.w-cr,cr,size.w,cr);
							g2.fillRect(0,0,size.w-cr,size.h);
							g2.fillRect(size.w-cr,cr,cr,size.h-cr);
						case RB:
							g2.fillArc(size.w-cr,size.h-cr,cr,Math.PI*2,Math.PI*.5);
							g2.fillTriangle(size.w,size.h-cr,size.w-cr,size.h-cr,size.w-cr,size.h);
							g2.fillRect(0,0,size.w,size.h-cr);
							g2.fillRect(0,size.h-cr,size.w-cr,cr);
						case LB:
							g2.fillArc(cr,size.h-cr,cr,Math.PI*.5,Math.PI);
							g2.fillTriangle(0,size.h-cr,cr,size.h-cr,cr,size.h);
							g2.fillRect(0,0,size.w,size.h-cr);
							g2.fillRect(cr,size.h-cr,size.w-cr,cr);
					}
				}
			}
		}

		_renderChildren(g2);
	}
}

enum Corner {
	LT;
	RT;
	RB;
	LB;
}