package hxfx.core.display;

class Rectangle extends DisplayBase {

    public var size:Size = new Size();
    public var color:kha.Color = kha.Color.Transparent;
    public var width:Float = 0;
    public var fillColor:kha.Color = kha.Color.Transparent;

    public function new() {}

    override public function render(g2: Graphics): Void {
        if(color.A == 0 && fillColor.A == 0) return; // Transparent, nothing to draw

        if(fillColor.A > 0) {
            g2.color = fillColor;
            g2.fillRect(0,0,size.w,size.h);
        }

        if(width > 0 && color != fillColor && color.A > 0) {
            g2.color = color;
            g2.drawRect(0,0,size.w,size.h, width);
        }
	}

}
