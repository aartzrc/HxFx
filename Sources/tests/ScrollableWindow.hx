package tests;

import hxfx.Window;
import hxfx.layout.*;

// Nothing working here, scroll bars not implemented
class ScrollableWindow extends Window {

	public static function main() {
		new ScrollableWindow("HxFx Test - ScrollableWindow");
	}

	override function onInit() {
		super.onInit();

		stage.backgroundColor = kha.Color.White;

		var scrollableDisplay = new ScrollableContainer();
		scrollableDisplay.layout.widthPercent = 100;
		scrollableDisplay.layout.heightPercent = 100;

		var gridDisplay = new GridContainer(6, 6);
		gridDisplay.layout.widthFixed = 600;
		gridDisplay.layout.heightFixed = 600;
		gridDisplay.gridNodeColorEven = kha.Color.fromFloats(0,0,0,.15);
		gridDisplay.parent = scrollableDisplay;

		scrollableDisplay.parent = stage;
	}
}