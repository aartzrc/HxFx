package tests;

import hxfx.Window;
import hxfx.layout.*;

class DualGridWindow extends Window {

	public static function main() {
		new DualGridWindow("HxFx Test - DualGridWindow");
	}

	override function onInit() {
		super.onInit();

		stage.backgroundColor = kha.Color.White;

		// Create a scaled and fixed grid and overlay using child nodes - test transparency
		var gridDisplay = new GridContainer(10, 10);
		gridDisplay.layout.widthPercent = 100;
		gridDisplay.layout.heightPercent = 100;
		gridDisplay.gridNodeColorEven = kha.Color.fromFloats(1,0,0,.15);

		gridDisplay.parent = stage;

		gridDisplay = new GridContainer(10, 10);
		gridDisplay.layout.widthFixed = 1000;
		gridDisplay.layout.heightFixed = 1000;
		gridDisplay.gridNodeColorOdd = kha.Color.fromFloats(0,0,1,.15);

		gridDisplay.parent = stage;
	}
}