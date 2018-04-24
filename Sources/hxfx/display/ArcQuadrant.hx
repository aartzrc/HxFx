package hxfx.display;

import hxfx.core.NodeBase;

using kha.graphics2.GraphicsExtension;

@:bindable
class ArcQuadrant extends NodeBase {
	public var arcRules(default,null):List<ArcRule>;

	public var quadrant(get,never):Quadrant;
	public var radius(get,never):Float;

	public function new() {
		super();
		arcRules = new List<ArcRule>();
	}

	public function setArcRule(newRule:ArcRule) {
		arcRules.add(newRule);
	}

	function get_quadrant() {
		var q = Quadrant.TL; // Default to top left quadrant
		for(r in arcRules) {
			switch(r) {
				case ArcQ(aq):
					q = aq;
				case _:
			}
		}

		return q;
	}

	function get_radius() {
		var useRadius:Float = 0; // Default to zero radius
		for(rule in arcRules) {
			switch(rule) {
				case Radius(r):
					useRadius = r;
					trace(useRadius);
				case _:
			}
		}

		return useRadius;
	}

	private override function _calcSize(layoutSize:Size) {
		return calcSize(this, layoutSize);
	}

	public static override function calcSize(arcNode:ArcQuadrant, size:Size) {
		var newSize = new Size({w:0, h:0});

		// Determine what size I want to be based on arc size - currently only for Quadrant types, so do simple calculations
		for(rule in arcNode.arcRules) {
			switch(rule) {
				case Radius(radius):
					newSize.w = radius;
					newSize.h = radius;
				case _:
					// TODO: Arc center position, start and end angles?
			}
		}

		return newSize;
	}

	override public function render(g2: Graphics): Void {
		// Override super to block full background draw

		// Fill background
		if(backgroundColor.A > 0) {
			g2.color = backgroundColor;
			
			switch(quadrant) {
				case TL:
					g2.fillArc(size.w,size.h,radius,Math.PI,Math.PI*1.5);
					g2.fillTriangle(0,size.h,size.w,size.h,size.w,0);
				case _:
			}
		}
		
		var lineWidth:Float = 0;
		for(r in arcRules) {
			switch(r) {
				case Width(w):
					lineWidth = w;
				case _:
			}
		}
		
		if(color.A > 0) {
			g2.color = color;
			
			switch(quadrant) {
				case TL:
					trace("drawArc: " + size.w + " : " +size.h);
					g2.drawArc(size.w,size.h,radius-(lineWidth/2),Math.PI,Math.PI*1.5,lineWidth);
				case _:
			}
		}

		_renderChildren(g2);
	}
}

enum ArcRule {
	CenterX(x:Align);
	CenterY(y:Align);
	Radius(r:Float);
	ArcQ(q:Quadrant);
	Width(w:Float);
	//SAngle(s:Float); // Not implemented yet, these would allow a arbitrary start and end angle
	//EAngle(e:Float);
}

enum Quadrant {
	TL;
	TR;
	BR;
	BL;
}