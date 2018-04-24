package tests;

import hxfx.Window;
import hxfx.layout.*;

class ScaleGridWindow extends Window {

	public static function main() {
		new ScaleGridWindow("HxFx Test - ScaleGridWindow");
	}

	override function onInit() {
		super.onInit();

		stage.settings.bgColor = kha.Color.White;

		// Create a 3x3 grid with edges that are fixed, fill middle - a typical border layout
		var gridDisplay = new GridContainer(3, 3);

		// Make the grid fill the container
		gridDisplay.settings.width = Percent(100);
		gridDisplay.settings.height = Percent(100);
		gridDisplay.settings.bgColor = kha.Color.fromFloats(0,1,0,.2);

		var borderSize = 50;

		// Set the top row to 50px tall and fixed to top
		for(c in gridDisplay.getRowCells(0)) {
			c.settings.height = Fixed(borderSize);
			c.settings.alignY = PercentLT(0);
		}

		// Set the bottom row to 50px tall and fixed to bottom
		for(c in gridDisplay.getRowCells(2)) {
			c.settings.height = Fixed(borderSize);
			c.settings.alignY = PercentRB(100);
		}

		// Set the left column to 50px width and fixed to left
		for(c in gridDisplay.getColumnCells(0)) {
			c.settings.width = Fixed(borderSize);
			c.settings.alignX = PercentLT(0);
		}

		// Set the right column to 50px width and fixed to right
		for(c in gridDisplay.getColumnCells(2)) {
			c.settings.width = Fixed(borderSize);
			c.settings.alignX = PercentRB(100);
		}

		// Set the middle row to fill the remaining space
		for(c in gridDisplay.getRowCells(1)) {
			c.settings.height = PercentLessFixed(100, borderSize*2);
			c.settings.alignY = PercentM(50);
		}

		// Set the middle column to fill the remaining space
		for(c in gridDisplay.getColumnCells(1)) {
			c.settings.width = PercentLessFixed(100, borderSize*2);
			c.settings.alignX = PercentM(50);
		}

		gridDisplay.parent = stage;
	}
}