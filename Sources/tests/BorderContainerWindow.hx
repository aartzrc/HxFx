package tests;

import hxfx.Window;
import hxfx.layout.*;
import hxfx.display.*;
import hxfx.core.data.Position;
import bindx.*;


class BorderContainerWindow extends Window {

	var testBind:Position;

	public static function main() {
		new BorderContainerWindow("HxFx Test - BorderContainerWindow");
	}

	override function onInit() {
		super.onInit();

		stage.setLayoutRule(BackgroundColor(kha.Color.White));

		var bordered = new BorderContainer();

        // Fill some space
		bordered.setLayoutRule(Width(LayoutSize.Percent(50)));
		bordered.setLayoutRule(Height(LayoutSize.Percent(50)));
        bordered.setLayoutRule(AlignX(PercentM(50)));
		bordered.setLayoutRule(AlignY(PercentM(50)));

        bordered.setLayoutRule(BackgroundColor(kha.Color.Red));

        bordered.setBorderRule(Color(kha.Color.Blue));
        bordered.setBorderRule(Width(5));
		//bordered.setBorderRule(CornerRadius(20));

        /*var arc = new ArcQuadrant();
        arc.setArcRule(Radius(50));
        arc.setArcRule(Width(5));
        arc.setLayoutRule(Color(kha.Color.Black));
        arc.setLayoutRule(BackgroundColor(kha.Color.White));
        arc.parent = bordered.viewport;*/

		bordered.parent = stage;

		testBind = new Position({x:0, y:0});
		Bind.bind(testBind.x, _testBind2);

		kha.Scheduler.addTimeTask(randomPosChange, 0, 1);
	}

	function _testBind2(from:Float, to:Float) {
		trace(from + " : " + to);
	}

	function _testBind(origin:IBindable, name:String, from:Dynamic, to:Dynamic) {
		trace(name);
	}

	function randomPosChange() {
		testBind.x += 1;
	}
}