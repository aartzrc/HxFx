package hxfx.core.data;

@:bindable
class Mouse implements IBindable  {
	public var x:Float = 0;
	public var xd:Float = 0;
	public var y:Float = 0;
	public var yd:Float = 0;
	public var b1down:Bool = false;
	public var b2down:Bool = false;
	public var b3down:Bool = false;

	public function new(windowId:Int) {
		// Start input listeners
		kha.input.Mouse.get().notifyWindowed(windowId, downListener, upListener, moveListener, wheelListener, leaveListener);
	}

	public function downListener(buttonNum:Int, x:Int, y:Int) {
		//trace("down: " + x + " " + y + " " + buttonNum);
		switch(buttonNum) {
			case 1: b1down = true;
			case 2: b2down = true;
			case 3: b3down = true;
		}
	}

	public function upListener(buttonNum:Int, x:Int, y:Int) {
		//trace("up: " + x + " " + y + " " + buttonNum);
		switch(buttonNum) {
			case 1: b1down = false;
			case 2: b2down = false;
			case 3: b3down = false;
		}
	}

	public function moveListener(m1:Int, m2:Int, m3:Int, m4:Int) {
		//trace("move: " + m1 + " " + m2 + " " + m3 + " " + m4);
		x=m1;
		y=m2;
		xd=m3;
		yd=m4;
	}

	public function wheelListener(w1:Int) {
		trace("wheel: " + w1);
	}

	public function leaveListener() {
		trace("leave");
	}
}