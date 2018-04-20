package hxfx.core.data;

import kha.input.KeyCode;

@:bindable
class Keyboard implements IBindable  {

	@:bindable
	public var keysDown:List<KeyCode>;
	@:bindable
	public var keyPress:String;
	
	public var cutCallback:Dynamic;
	public var copyCallback:Dynamic;
	public var pasteCallback:Dynamic;
	
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
		if(cutCallback != null)
			return cutCallback();
		return null;
	}

	public function copyListener():String {
		if(copyCallback != null)
			return copyCallback();
		return null;
	}

	public function pasteListener(paste:String) {
		if(pasteCallback != null)
			pasteCallback(paste);
	}
}