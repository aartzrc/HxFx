package tests;

import hxfx.Window;
import hxfx.layout.*;

class FixedGridWindow extends Window {

	public static function main() {
		new FixedGridWindow("HxFx Test - FixedGridWindow");
	}

	override function onInit() {
		super.onInit();

		stage.backgroundColor = kha.Color.White;

		var gridDisplay = new GridContainer(10, 10);
		gridDisplay.layout.widthFixed = 1000;
		gridDisplay.layout.heightFixed = 1000;
		gridDisplay.gridNodeColorEven = kha.Color.fromFloats(0,0,0,.15);

		gridDisplay.parent = stage;
	}
}