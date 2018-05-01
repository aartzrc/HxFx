package hxfx.layout;

import hxfx.core.NodeBase;
import hxfx.core.display.ArcQuadrant;
import hxfx.core.display.Rectangle;

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

	public var viewport:AbsoluteContainer;
	var viewportCell:NodeBase;

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

		viewportCell = getCell(1,1);
		viewportCell.settings.width = Percent(100);
		viewportCell.settings.height = Percent(100);
		viewportCell.settings.alignX = PercentM(50);
		viewportCell.settings.alignY = PercentM(50);
		viewport = new AbsoluteContainer();
		viewport.settings.width = Percent(100);
		viewport.settings.height = Percent(100);
		viewport.settings.alignX = FixedLT(0); //PercentM(50);
		viewport.settings.alignY = FixedLT(0); //PercentM(50);
		viewport.settings.fitToChildren = true; // Grow viewport as needed to fit all children

		viewport.parent = viewportCell; // Attach to the center cell
		viewportCell.settings.overflowHidden = true; // Scissor any viewport overflow
		
		setChildIndex(viewportCell, _childNodes.length-1); // Make the viewport render last
		
		Bind.bind(borderContainerSettings.bgColor, setBGColor);

		Bind.notify(borderContainerSettings.borderWidth, borderContainerSettings.borderWidth,borderContainerSettings.borderWidth);
	}

	public var borderContainerSettings(get,never):BorderContainerSettings;

	public function get_borderContainerSettings() {
		return cast settings;
	}

	function setBGColor(from:kha.Color, to:kha.Color) {
		viewport.settings.bgColor = to;
	}

	override function _thisHitBounds() {
		// No hit bounds for the container, just compile child hit bounds
	}

	public function updateBorders() {
		// Recalc all borders

		// How much extra edges should have to work with a rounded corner
		var cornerSize = cornerLT.cornerDisplay.size;
		var viewportOffset = cornerLT.viewportOffset;

		top.parent.settings.width = PercentLessFixed(100, cornerSize*2);
		top.parent.settings.height = Fixed(viewportOffset);
		bottom.parent.settings.width = PercentLessFixed(100, cornerSize*2);
		bottom.parent.settings.height = Fixed(viewportOffset);
		left.parent.settings.height = PercentLessFixed(100, cornerSize*2);
		left.parent.settings.width = Fixed(viewportOffset);
		right.parent.settings.height = PercentLessFixed(100, cornerSize*2);
		right.parent.settings.width = Fixed(viewportOffset);

		viewportCell.settings.width = PercentLessFixed(100, viewportOffset*2);
		viewportCell.settings.height = PercentLessFixed(100, viewportOffset*2);
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

	var borderRectangle:Rectangle = new Rectangle(); // borderRectangle does the drawing and provides SVG output
	var border:AbsoluteContainer = new AbsoluteContainer(); // border container is a 'helper' that responds to layout, updates are pushed to borderRectangle
	var fill:AbsoluteContainer = new AbsoluteContainer(); // the background fill when drawing to screen

	public function new(container:BorderContainer, edge:Edge) {
		super();
        this.edge = edge;
		this.container = container;

		_init();
		
		Bind.bind(container.borderContainerSettings.borderWidth, setBorderWidth);
		Bind.bind(container.borderContainerSettings.borderColor, setBorderColor);
		Bind.bind(container.borderContainerSettings.bgColor, setBGColor);
		Bind.bind(container.borderContainerSettings.resizeable, setResizable);
		Bind.bind(border.size.w, setBorderRectangleSize);
		Bind.bind(border.size.h, setBorderRectangleSize);
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
		trace(to);
		switch(edge) {
			case Top, Bottom:
				border.settings.height = Fixed(to);
				fill.settings.height = PercentLessFixed(100, to);
			case Left, Right:
				border.settings.width = Fixed(to);
				fill.settings.width = PercentLessFixed(100, to);
		}
    }

	function setBorderRectangleSize(from:Float, to:Float) {
		borderRectangle.size.w = size.w;
		borderRectangle.size.h = size.h;
	}

	function setBorderColor(from:Color, to:Color) {
		borderRectangle.fillColor = to;
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
				container.settings.width = Fixed(container.mouseData.x + (container.borderContainerSettings.borderWidth/2));
			case Bottom:
				container.settings.height = Fixed(container.mouseData.y + (container.borderContainerSettings.borderWidth/2));
		}
	}

	override public function render(g2: Graphics): Void {
		borderRectangle.render(g2);

		_renderChildren(g2);
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
    public var cornerDisplay:ArcQuadrant = new ArcQuadrant();
	public var container:BorderContainer;

	public function new(container:BorderContainer, corner:Quadrant) {
		super();
        cornerDisplay.corner = corner;
		this.container = container;

		_init();
		
		Bind.bind(container.borderContainerSettings.borderWidth, setWidthOrRadius);
		Bind.bind(container.borderContainerSettings.borderColor, setBorderColor);
		Bind.bind(container.settings.bgColor, setBackgroundColor);
		Bind.bind(container.borderContainerSettings.borderCornerRadius, setWidthOrRadius);
		Bind.bind(container.borderContainerSettings.resizeable, setResizable);
	}

	function _init() {
		// Fill the corner
		settings.width = Percent(100);
		settings.height = Percent(100);

		switch(cornerDisplay.corner) {
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
		switch(cornerDisplay.corner) {
			case LT, RT, LB:
				// No resize cursor
			case RB:
				settings.cursor = "nwse-resize";
				Bind.bind(mouseData.b1down, mouseDown);
		}
	}

	override function _thisHitBounds() {
		switch(cornerDisplay.corner) {
			case LT:
				_hitBoundsCache.bounds.push(new Circle({position: {x:size.w, y:size.h}, radius: cornerDisplay.radius}));
			case RT:
				_hitBoundsCache.bounds.push(new Circle({position: {x:0, y:size.h}, radius: cornerDisplay.radius}));
			case RB:
				_hitBoundsCache.bounds.push(new Circle({position: {x:0, y:0}, radius: cornerDisplay.radius}));
			case LB:
				_hitBoundsCache.bounds.push(new Circle({position: {x:size.w, y:0}, radius: cornerDisplay.radius}));
		}
	}

	function setWidthOrRadius(from:Float, to:Float) {
		cornerDisplay.width = container.borderContainerSettings.borderWidth;
		cornerDisplay.radius = container.borderContainerSettings.borderCornerRadius;

		parent.settings.width = Fixed(cornerDisplay.size);
		parent.settings.height = Fixed(cornerDisplay.size);

		container.updateBorders();
    }

	function setBorderColor(from:Color, to:Color) {
		cornerDisplay.color = to;
    }

	function setBackgroundColor(from:Color, to:Color) {
		cornerDisplay.bgColor = to;
    }

	public var viewportOffset(get, never):Float;

	function get_viewportOffset() {
		var s = container.borderContainerSettings;
		var insideRadius = s.borderCornerRadius-s.borderWidth;
		//var insideRadius = s.borderCornerRadius;
		if(insideRadius<0) return s.borderWidth;
		return cornerDisplay.size - (insideRadius*.6); // Technically sqrt(1/2r) to get sin @ 45deg - approx .7, leave margin with .6
	}

	function mouseDown(from:Bool, to:Bool) {
		if(to && mouseData.mouseInBounds) {
			if(container.dragFocus == null) {
				container.dragFocus = this;
				switch(cornerDisplay.corner) {
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
		switch(cornerDisplay.corner) {
			case LT, RT, LB:
				// No resize?
			case RB:
				var cornerOffset = cornerDisplay.radius * .3 + cornerDisplay.width/2;
				container.settings.height = Fixed(container.mouseData.y + cornerOffset);
				container.settings.width = Fixed(container.mouseData.x + cornerOffset);
		}
	}

	override public function render(g2: Graphics): Void {
		cornerDisplay.render(g2);

		_renderChildren(g2);
	}
}