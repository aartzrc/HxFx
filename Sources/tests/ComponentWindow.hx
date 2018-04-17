package tests;

import hxfx.Window;
import kha.Assets;
import kha.Font;
import kha.System;
import hxfx.layout.*;
import hxfx.widget.*;
import bindx.*;

class ComponentWindow extends Window {

	public static var arial:Font;
	var text:Text;

	public static function main() {
		new ComponentWindow("HxFx Test - ComponentWindow");
	}

	override function onInit() {
		trace("Loading Arial.ttf");
		//Assets.loadEverything(function()
		Assets.loadFont("arial", function(loaded:Font)
		{
			//arial = Assets.fonts.ARIALUNI;
			arial = Assets.fonts.arial;
			// Assets loaded, try render
			System.renderNextFrame = true;
		});
		super.onInit();

		stage.backgroundColor = kha.Color.White;

		var emptyDisplay = new AbsoluteContainer();
		emptyDisplay.layout.heightPercent = 100;
		emptyDisplay.layout.widthPercent = 100;
		emptyDisplay.layout.marginLeftFixed = 20;
		emptyDisplay.layout.marginTopFixed = 20;

		/*text = new Text();
		text.text = "test";
		text.parent = emptyDisplay;*/
		var letter = new Glyph();
		letter.glyph = "A";
		letter.parent = emptyDisplay;

		emptyDisplay.parent = stage;

		//kha.Scheduler.addTimeTask(randomTextChange, 0, 4, 10);
	}

	public function randomTextChange() {
		//trace("rand..");
		text.text += String.fromCharCode(Std.random(26)+65);

		//trace(text.characterRects);
	}

	
}