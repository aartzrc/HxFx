package hxfx.core.data;

@:bindable
class MouseData implements IBindable  {
	public var x:Float = 0;
	public var xd:Float = 0;
	public var y:Float = 0;
	public var yd:Float = 0;
	public var b1down:Bool = false;
	public var b2down:Bool = false;
	public var b3down:Bool = false;
	public var wheeld:Int = 0;
	public var wheel:Int = 0;
	public var mouseInBounds:Bool = false;
	public var b1doubleclicked:Bool = false;

	public function new() {}
}

@:bindable
class Mouse implements IBindable  {
	inline static var dblClickDelay:Float = .2;
	public var mouseData:MouseData;

	public function new(windowId:Int) {
		// Start input listeners
		var khaMouse = kha.input.Mouse.get(windowId);
		//trace(khaMouse);
		khaMouse.notifyWindowed(windowId, downListener, upListener, moveListener, wheelListener, leaveListener);
		mouseData = new MouseData();
		Bind.bind(mouseData.b1down, _dblClickCheck);
	}

	var downCount:Int = 0;
	var downTimer:Int = -1;
	private function _dblClickCheck(from:Bool, to:Bool) {
		if(to) {
			if(downTimer != -1) kha.Scheduler.removeTimeTask(downTimer); // Remove the old dbl-click task
			downTimer = kha.Scheduler.addTimeTask(_dblClickEnd, dblClickDelay, dblClickDelay); // Create a new timer to watch for dbl-click
			downCount++;
			if(downCount>=2) mouseData.b1doubleclicked = true;
		}
	}

	private function _dblClickEnd() {
		downCount = 0;
		mouseData.b1doubleclicked = false;
		kha.Scheduler.removeTimeTask(downTimer);
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