package hxfx.display;

import hxfx.core.NodeBase;
import hxfx.layout.BorderContainer;

@:bindable
class BorderEdge extends NodeBase {
    public var edge:Edge = Edge.Top;
	public var container:BorderContainer;

	public function new(container:BorderContainer, edge:Edge) {
		super();
        this.edge = edge;
		this.container = container;
		Bind.bind(container.borderWidth, setWidth);
	}

    function setWidth(from:Float, to:Float) {
		trace(to);
        //width = to;
		switch(edge) {
			case Top:
				// Set the top row to w tall and fixed to top
				setLayoutRule(Height(LayoutSize.Fixed(container.borderWidth)));
				setLayoutRule(BaseRule.AlignY(Align.PercentLT(0)));
			case _:
		}
    }

	override public function render(g2: Graphics): Void {
		super.render(g2);

		if(color.A > 0) {
			g2.color = color;
			
			trace(edge);
			switch(edge) {
                case Left:
                    g2.fillRect(0,0,container.borderWidth,size.h);
                case Right:
                    g2.fillRect(size.w-container.borderWidth,0,container.borderWidth,size.h);
				case Top:
					g2.fillRect(0,0,size.w,container.borderWidth);
				case Bottom:
                    g2.fillRect(0,size.h-container.borderWidth,size.w,container.borderWidth);
			}
			g2.color = kha.Color.Black;
			g2.drawRect(0,0,size.w,size.h);
		}

		_renderChildren(g2);
	}
}

enum Edge {
	Left;
	Right;
	Top;
	Bottom;
}