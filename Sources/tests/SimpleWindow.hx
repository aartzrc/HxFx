package tests;

import hxfx.Window;
import hxfx.layout.*;
import hxfx.widget.*;

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
			text.setFontRule(FontRule.Font(arial));
		});

		// Any way to block the array from modification?
		//stage.layoutRules.push(bgColor);
		stage.setLayoutRule(BackgroundColor(kha.Color.White));

		//var block = new AbsoluteContainer();
		var block = new BorderContainer();
		block.borderColor = kha.Color.Blue;
		block.setLayoutRule(BackgroundColor(kha.Color.fromFloats(0,0,0,.15)));
		block.setLayoutRule(Width(LayoutSize.Percent(50)));
		block.setLayoutRule(Height(LayoutSize.Fixed(30)));
		//block.setLayoutRule(Width(LayoutSize.Fixed(150)));
		block.setLayoutRule(HAlign(Align.PercentMiddle(50)));
		block.setLayoutRule(VAlign(Align.PercentMiddle(25)));
		//block.setLayoutRule(Cursor("pointer"));

		text = new TextField();
		text.text = "testing 1234 ...";
		//text.text = "test";
		text.setLayoutRule(Color(kha.Color.Red));
		text.setFontRule(FontSize(50));
		//text.setLayoutRule(HAlign(Align.PercentMiddle(50)));
		//text.setLayoutRule(HAlign(Align.FixedLT(10)));
		text.setLayoutRule(VAlign(Align.PercentMiddle(50)));
		text.setLayoutRule(Cursor("text"));

		text.parent = block;

		block.parent = stage;

		//kha.Scheduler.addTimeTask(randomTextChange, 0, 1);
	}

	var randString:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ     !@#$%^&*()-+";
	public function randomTextChange() {
		//trace("rand..");
		var pos = Std.random(randString.length+10);
		// Delete character
		if(pos>randString.length && text.text.length>0) {
			text.text = text.text.substring(0, text.text.length-1);
		} else {
			text.text += randString.charAt(pos);
		}

		trace(text.text);
	}
}