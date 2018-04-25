package tests;

import hxfx.Window;
import hxfx.layout.*;
import hxfx.widget.*;

import kha.*;

class SimpleWindow extends Window {

	public static function main() {
		new SimpleWindow("HxFx Test - SimpleWindow");
	}

	//var text:TextField;
	var textFields:Array<TextField>;

	override function onInit() {
		super.onInit();

		//Assets.loadFont("Kroftsmann", function(arial:Font)
		//Assets.loadFont("DejaVuSansMono", function(arial:Font)
		Assets.loadFont("arialsmall", function(arial:Font)
		//Assets.loadFont("arial", function(arial:Font)
		{
			//text.setFontRule(FontRule.Font(arial));
			for(t in textFields) {
				t.fontSettings.font = arial;
			}
		});

		// Any way to block the array from modification?
		//stage.layoutRules.push(bgColor);
		stage.settings.bgColor = kha.Color.White;

		//var block = new AbsoluteContainer();
		var block = new BorderContainer();
		//block.setBorderRule(Color(kha.Color.Blue));
		block.settings.bgColor = kha.Color.fromFloats(0,0,0,.15);
		block.settings.width = Percent(50);
		block.settings.height = Fixed(30);
		block.settings.alignX = PercentM(50);
		block.settings.alignY = PercentM(25);
		//block.setLayoutRule(Cursor("pointer"));

		textFields = new Array<TextField>();
		for(i in 0 ... 1) {
			var text = new TextField();
			//text.text = "testing 1234 ...";ГД
			//text.text = "xxГДxx中文xx";
			text.text = "Get the currently highlighted text";
			//trace(text.text);
			//text.text = "test";
			text.settings.color = kha.Color.Black;
			text.fontSettings.fontSize = 20;
			//text.setLayoutRule(HAlign(Align.PercentMiddle(50)));
			//text.setLayoutRule(HAlign(Align.FixedLT(10)));
			//text.setLayoutRule(VAlign(Align.PercentMiddle(50)));
			//text.setLayoutRule(VAlign(Align.FixedM(i*10)));
			//text.setLayoutRule(HAlign(Align.FixedLT(i%10 * 100)));
			text.settings.cursor = "text";

			textFields.push(text);

			text.parent = block;
		}

		block.parent = stage;

		//kha.Scheduler.addTimeTask(randomTextChange, 0, 1);
	}

	var randString:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ     !@#$%^&*()-+";
	public function randomTextChange() {
		//trace("rand..");
		for(text in textFields) {
			var pos = Std.random(randString.length+10);
			// Delete character
			if(pos>randString.length && text.text.length>0) {
				text.text = text.text.substring(0, text.text.length-1);
			} else {
				text.text += randString.charAt(pos);
			}
		}

		//trace(text.text);
	}
}