package hxfx.core.data;

import kha.input.KeyCode;

@:bindable
class Keyboard implements IBindable  {

	@:bindable
	public var keysDown:List<KeyCode>;
	@:bindable
	public var keyPress:String;
	
	public function new(?keyboardNum:Int) {
		keysDown = new List<KeyCode>();

		// Start input listeners
		var khaKeyboard = kha.input.Keyboard.get(keyboardNum);
		khaKeyboard.notify(downListener, upListener, pressListener);
		kha.System.notifyOnCutCopyPaste(cutListener, copyListener, pasteListener);
	}

	public function downListener(key:KeyCode) {
		//trace("down:" + key);
		keysDown.push(key);
		var to = new List<KeyCode>();
		to.add(key);
		Bind.notify(this.keysDown, new List<KeyCode>(), to);
	}

	public function upListener(key:KeyCode) {
		//trace("up:" + key);
		keysDown.remove(key);
		var from = new List<KeyCode>();
		from.add(key);
		Bind.notify(this.keysDown, from, new List<KeyCode>());
		keyPress = null;
	}

	public function pressListener(press:String) {
		keyPress = press;
	}

	public function cutListener():String {
		trace("cut");
		return "";
	}

	public function copyListener():String {
		trace("copy");
		return "";
	}

	public function pasteListener(paste:String) {
		trace("paste");
		trace(paste);
	}
}