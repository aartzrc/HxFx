package hxfx.core.display;

using kha.graphics2.GraphicsExtension;

/**
 *  Base class for display pieces - use this for all items that need to output to display or svg
 */
class ArcQuadrant extends DisplayBase {

    public var corner:Quadrant = Quadrant.LT;
    public var radius:Float = 0;
    public var width:Float = 0;
    public var color:kha.Color = kha.Color.Transparent;
    public var bgColor:kha.Color = kha.Color.Transparent;

    public function new() {}

    public var size(get, never):Float;

	function get_size() {
		var d = width;
		// Calculate for rounded corners
		if(radius > width) {
			d = radius;
		}
		return d;
	}

    override public function render(g2: Graphics): Void {
        if(color.A == 0) return; // Transparent, nothing to draw
        if(radius == 0) return; // Too small, nothing to draw

		if(radius <= 0) {
			// No radius, just draw a rectangle of width/height
			g2.color = color;
            g2.fillRect(0,0,width,width);
		} else {			
			if(width<radius) { // Border is less than radius, draw 'stroked' arc
				// Draw the arc
                g2.color = color;
                
                // drawArc with width does not fully fill - not sure if this is Kha or underlying WebGL problem
                // workaround is to do a fillArc and take a bite out of it - this will not work with a transparent background!
                switch(corner) {
                    case LT:
                        //g2.drawArc(size,size,radius-(width/2),Math.PI,Math.PI*1.5,width); 
                        g2.fillArc(radius,radius,radius,Math.PI,Math.PI*1.5);
                        g2.fillTriangle(0,radius,radius,radius,radius,0);
                        g2.fillRect(0,radius,size,size-radius);
                        g2.fillRect(radius,0,size-radius,radius);
                    case RT:
                        //g2.drawArc(0,size,radius-(width/2),Math.PI*1.5,Math.PI*2,width);
                        g2.fillArc(size-radius,radius,radius,Math.PI*1.5,Math.PI*2);
                        g2.fillTriangle(size-radius,0,size-radius,radius,size,radius);
                        g2.fillRect(0,0,size-radius,size);
                        g2.fillRect(size-radius,radius,radius,size-radius);
                    case RB:
                        //g2.drawArc(0,0,radius-(width/2),Math.PI*2,Math.PI*.5,width);
                        g2.fillArc(size-radius,size-radius,radius,Math.PI*2,Math.PI*.5);
                        g2.fillTriangle(size,size-radius,size-radius,size-radius,size-radius,size);
                        g2.fillRect(0,0,size,size-radius);
                        g2.fillRect(0,size-radius,size-radius,radius);
                    case LB:
                        //g2.drawArc(size,0,radius-(width/2),Math.PI*.5,Math.PI,width);
                        g2.fillArc(radius,size-radius,radius,Math.PI*.5,Math.PI);
                        g2.fillTriangle(0,size-radius,radius,size-radius,radius,size);
                        g2.fillRect(0,0,size,size-radius);
                        g2.fillRect(radius,size-radius,size-radius,radius);
				}

				// Fill background
				if(bgColor.A > 0) {
					g2.color = bgColor;
					
					switch(corner) {
						case LT:
							g2.fillArc(size,size,radius - width,Math.PI,Math.PI*1.5);
							g2.fillTriangle(width,size,size,size,size,width);
						case RT:
							g2.fillArc(0,size,radius - width,Math.PI*1.5,Math.PI*2);
							g2.fillTriangle(0,size,size-width,size,0,width);
						case RB:
							g2.fillArc(0,0,radius - width,Math.PI*2,Math.PI*.5);
							g2.fillTriangle(0,0,size-width,0,0,size-width);
						case LB:
							g2.fillArc(size,0,radius - width,Math.PI*.5,Math.PI);
							g2.fillTriangle(size,0,size,size-width,width,0);
					}
				}
			} else {
				// Corner is less than border radius, draw a filled corner
                g2.color = color;
                
                switch(corner) {
                    case LT:
                        g2.fillArc(radius,radius,radius,Math.PI,Math.PI*1.5);
                        g2.fillTriangle(0,radius,radius,radius,radius,0);
                        g2.fillRect(0,radius,size,size-radius);
                        g2.fillRect(radius,0,size-radius,radius);
                    case RT:
                        g2.fillArc(size-radius,radius,radius,Math.PI*1.5,Math.PI*2);
                        g2.fillTriangle(size-radius,0,size-radius,radius,size,radius);
                        g2.fillRect(0,0,size-radius,size);
                        g2.fillRect(size-radius,radius,radius,size-radius);
                    case RB:
                        g2.fillArc(size-radius,size-radius,radius,Math.PI*2,Math.PI*.5);
                        g2.fillTriangle(size,size-radius,size-radius,size-radius,size-radius,size);
                        g2.fillRect(0,0,size,size-radius);
                        g2.fillRect(0,size-radius,size-radius,radius);
                    case LB:
                        g2.fillArc(radius,size-radius,radius,Math.PI*.5,Math.PI);
                        g2.fillTriangle(0,size-radius,radius,size-radius,radius,size);
                        g2.fillRect(0,0,size,size-radius);
                        g2.fillRect(radius,size-radius,size-radius,radius);
                }
			}
		}
	}

}

enum Quadrant {
	LT;
	RT;
	RB;
	LB;
}