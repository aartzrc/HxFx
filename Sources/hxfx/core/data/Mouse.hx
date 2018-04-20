package hxfx.core.data;

@:bindable
class Mouse implements IBindable  {
	public var mouseData:MouseData;

	public function new(windowId:Int) {
		// Start input listeners
		var khaMouse = kha.input.Mouse.get(windowId);
		//trace(khaMouse);
		khaMouse.notifyWindowed(windowId, downListener, upListener, moveListener, wheelListener, leaveListener);
		mouseData = new MouseData();
	}

	public function downListener(buttonNum:Int, x:Int, y:Int) {
		//trace("down: " + x + " " + y + " " + buttonNum);
		switch(buttonNum) {
			case 0: mouseData.b1down = true;
			case 1: mouseData.b2down = true;
			case 2: mouseData.b3down = true;
		}
	}

	public function upListener(buttonNum:Int, x:Int, y:Int) {
		//trace("up: " + x + " " + y + " " + buttonNum);
		switch(buttonNum) {
			case 0: mouseData.b1down = false;
			case 1: mouseData.b2down = false;
			case 2: mouseData.b3down = false;
		}
	}

	public function moveListener(m1:Int, m2:Int, m3:Int, m4:Int) {
		//trace("move: " + m1 + " " + m2 + " " + m3 + " " + m4);
		mouseData.x=m1;
		mouseData.y=m2;
		mouseData.xd=m3;
		mouseData.yd=m4;
		mouseData.mouseInBounds = true;
	}

	public function wheelListener(w1:Int) {
		//trace("wheel: " + w1);
		mouseData.wheeld = w1;
		mouseData.wheel+=w1;
	}

	public function leaveListener() {
		//trace("leave");
		mouseData.mouseInBounds = false;
	}
}