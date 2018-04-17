package tests;

import hxfx.Window;
import hxfx.layout.*;
import hxfx.core.NodeBase;

import bindx.*;

class DualGridWindow extends Window implements IBindable {

	public static function main() {
		new DualGridWindow("HxFx Test - DualGridWindow");
	}

	public var watchChild:NodeBase;
	public var percentGrid:GridContainer;
	public var fixedGrid:GridContainer;
	@:bindable
	public var gridX:Int = 4;
	@:bindable
	public var gridY:Int = 4;

	override function onInit() {
		super.onInit();

		// Create a scaled and fixed grid and overlay using child nodes - test transparency
		fixedGrid = new GridContainer(10, 10);
		//fixedGrid.layout.widthFixed = 1000;
		//fixedGrid.layout.heightFixed = 1000;
		fixedGrid.layout.widthPercent = 80;
		fixedGrid.layout.heightFixed = 1000;
		fixedGrid.gridNodeColorOdd = kha.Color.fromFloats(0,0,1,.15);

		fixedGrid.parent = stage;

		percentGrid = new GridContainer(2, 2);
		percentGrid.layout.widthPercent = 100;
		percentGrid.layout.heightPercent = 100;
		percentGrid.gridNodeColorEven = kha.Color.fromFloats(1,0,0,.15);

		percentGrid.parent = fixedGrid.getChild(gridX,gridY);

		watchChild = percentGrid.getChild(1,1);
		watchChild.mouseSubscribe = true;
		Bind.bindAll(watchChild.mouseData, childMouseMove);
		Bind.bind(this.gridX, moveGridX);
		Bind.bind(this.gridY, moveGridY);
	}

	public function moveGridX(from:Int, to:Int) {
		fixedGrid.setChild(null, from, gridY);
		fixedGrid.setChild(percentGrid, to, gridY);
		draggingNode = false;
	}

	public function moveGridY(from:Int, to:Int) {
		fixedGrid.setChild(null, gridX, from);
		fixedGrid.setChild(percentGrid, gridX, to);
		draggingNode = false;
	}

	var draggingNode = false;
	public function childMouseMove(name:String, from:Dynamic, to:Dynamic) {
		trace(name + " : " + to);
		if(watchChild.mouseData.b1down && watchChild.mouseInBounds) {
			percentGrid.gridNodeColorOdd = kha.Color.fromFloats(0,1,0,.15);
			draggingNode = true;
		} else if(draggingNode) {
			if(watchChild.mouseData.b1down) {
				// Moved out of bounds while dragging
				if(watchChild.mouseData.x>watchChild.size.width) {
					gridX++;
				}
				if(watchChild.mouseData.y>watchChild.size.height) {
					gridY++;
				}
				if(watchChild.mouseData.x<0) {
					gridX--;
				}
				if(watchChild.mouseData.y<0) {
					gridY--;
				}
				trace(gridX + " : " + gridY);
			} else {
				percentGrid.gridNodeColorOdd = kha.Color.Transparent;
				draggingNode = false;
			}
		}

	}
}