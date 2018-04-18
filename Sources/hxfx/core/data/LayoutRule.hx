package hxfx.core.data;

enum LayoutRule {
	// Position/size
	Width(v:LayoutSize);
	HAlign(v:Align);
	Height(v:LayoutSize);
	VAlign(v:Align);
	
	// Color
	BackgroundColor(c:Color);
	Color(c:Color);

	// Font
	Font(f:kha.Font);
	FontSize(s:Float);

	// Cursor/pointer - in html target, this pushes to the DOM - see cursor names here: https://www.w3schools.com/cssref/playit.asp?filename=playcss_cursor&preval=copy
	Cursor(name:String);
}

enum LayoutSize {
	Fixed(v:Float);
	Percent(v:Float);
}

enum Align {
	FixedLT(v:Float); // Left or top edge of node is in a fixed position
	FixedM(v:Float); // Middle of node is in a fixed position
	FixedRB(v:Float); //Right or bottom edge of node is in a fixed position
	PercentMiddle(v:Float); // Middle of node is a percent position from left of layout area
}