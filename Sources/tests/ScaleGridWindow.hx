package tests;

import hxfx.Window;
import hxfx.layout.*;

class ScaleGridWindow extends Window {

	public static function main() {
		new ScaleGridWindow("HxFx Test - ScaleGridWindow");
	}

	override function onInit() {
		super.onInit();

		stage.backgroundColor = kha.Color.White;

		var gridDisplay = new GridContainer(10, 10);
		gridDisplay.layout.widthPercent = 100;
		gridDisplay.layout.heightPercent = 100;
		gridDisplay.gridNodeColorEven = kha.Color.fromFloats(0,0,0,.15);

		gridDisplay.parent = stage;
	}
}