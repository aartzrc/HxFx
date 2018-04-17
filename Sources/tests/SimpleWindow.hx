package tests;

import hxfx.Window;
import hxfx.layout.*;
import hxfx.widget.Text;

class SimpleWindow extends Window {

	public static function main() {
		new SimpleWindow("HxFx Test - SimpleWindow");
	}

	override function onInit() {
		super.onInit();

		//stage.backgroundColor = kha.Color.Blue;
		//stage.backgroundColor = kha.Color.Transparent;

		var block = new AbsoluteContainer();
		block.backgroundColor = kha.Color.Green;
		block.layout.marginLeftFixed = 10;
		block.layout.marginTopFixed = 10;
		block.layout.widthFixed = 200;
		block.layout.heightFixed = 100;

		var text = new Text();
		text.text = "test";

		text.parent = block;

		block.parent = stage;

		Bind.bind(this.)
	}
}