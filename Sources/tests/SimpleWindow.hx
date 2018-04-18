package tests;

import hxfx.Window;
import hxfx.layout.*;
import hxfx.core.data.LayoutRule;
import hxfx.widget.TextField;

import kha.*;

class SimpleWindow extends Window {

	public static function main() {
		new SimpleWindow("HxFx Test - SimpleWindow");
	}

	var text:TextField;

	override function onInit() {
		super.onInit();

		Assets.loadFont("arial", function(arial:Font)
		{
			text.setLayoutRule(LayoutRule.Font(arial));
			System.renderNextFrame = true;
			//trace("Font loaded: Render");
		});

		// Any way to block the array from modification?
		//stage.layoutRules.push(bgColor);
		stage.setLayoutRule(LayoutRule.BackgroundColor(kha.Color.White));

		//var block = new AbsoluteContainer();
		var block = new BorderContainer();
		block.borderColor = kha.Color.Blue;
		block.setLayoutRule(LayoutRule.BackgroundColor(kha.Color.fromFloats(0,0,0,.15)));
		block.setLayoutRule(LayoutRule.Width(LayoutSize.Percent(50)));
		block.setLayoutRule(LayoutRule.Height(LayoutSize.Fixed(100)));
		//block.setLayoutRule(LayoutRule.Width(LayoutSize.Fixed(150)));
		block.setLayoutRule(LayoutRule.HAlign(Align.PercentMiddle(50)));
		block.setLayoutRule(LayoutRule.VAlign(Align.PercentMiddle(25)));
		block.setLayoutRule(LayoutRule.Cursor("pointer"));

		text = new TextField();
		text.text = "TeStInG";
		text.setLayoutRule(LayoutRule.Color(kha.Color.Red));
		text.setLayoutRule(LayoutRule.FontSize(20));
		text.setLayoutRule(LayoutRule.HAlign(Align.PercentMiddle(50)));
		text.setLayoutRule(LayoutRule.VAlign(Align.PercentMiddle(50)));
		text.setLayoutRule(LayoutRule.Cursor("text"));

		text.parent = block;

		block.parent = stage;

		kha.Scheduler.addTimeTask(randomTextChange, 0, 4, 10);
	}

	public function randomTextChange() {
		//trace("rand..");
		text.text += String.fromCharCode(Std.random(26)+65);
	}
}