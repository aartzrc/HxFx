package tests;

import hxfx.Window;
import hxfx.layout.*;

class ScaleGridWindow extends Window {

	public static function main() {
		new ScaleGridWindow("HxFx Test - ScaleGridWindow");
	}

	override function onInit() {
		super.onInit();

		stage.setLayoutRule(BackgroundColor(kha.Color.White));

		// Create a 3x3 grid with edges that are fixed, fill middle - a typical border layout
		var gridDisplay = new GridContainer(3, 3);

		// Make the grid fill the container
		gridDisplay.setLayoutRule(Width(LayoutSize.Percent(100)));
		gridDisplay.setLayoutRule(Height(LayoutSize.Percent(100)));

		// Set the top row to 50px tall and fixed to top
		gridDisplay.setRowLayoutRule(0, Height(LayoutSize.Fixed(50)));
		gridDisplay.setRowLayoutRule(0, BaseRule.VAlign(Align.PercentLT(0)));

		// Set the bottom row to 50px tall and fixed to bottom
		gridDisplay.setRowLayoutRule(2, Height(LayoutSize.Fixed(50)));
		gridDisplay.setRowLayoutRule(2, BaseRule.VAlign(Align.PercentRB(100)));

		// Set the left column to 50px width and fixed to left
		gridDisplay.setColumnLayoutRule(0, Width(LayoutSize.Fixed(50)));
		gridDisplay.setColumnLayoutRule(0, BaseRule.HAlign(Align.PercentLT(0)));

		// Set the left column to 50px width and fixed to right
		gridDisplay.setColumnLayoutRule(2, Width(LayoutSize.Fixed(50)));
		gridDisplay.setColumnLayoutRule(2, BaseRule.HAlign(Align.PercentRB(100)));

		// Set the middle row to fill the remaining space
		gridDisplay.setRowLayoutRule(1, Height(LayoutSize.PercentLessFixed(100, 100)));
		gridDisplay.setRowLayoutRule(1, BaseRule.VAlign(Align.FixedLT(50)));

		// Set the middle column to fill the remaining space
		gridDisplay.setColumnLayoutRule(1, Width(LayoutSize.PercentLessFixed(100, 100)));
		gridDisplay.setColumnLayoutRule(1, BaseRule.HAlign(Align.FixedLT(50)));

		gridDisplay.parent = stage;
	}
}