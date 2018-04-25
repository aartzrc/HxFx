package tests;

import hxfx.Window;
import hxfx.layout.*;
import hxfx.widget.TextField;

class BorderContainerWindow extends Window {
	public static function main() {
		new BorderContainerWindow("HxFx Test - BorderContainerWindow");
	}

	var bordered:BorderContainer;
	var textField:TextField;

	override function onInit() {
		super.onInit();

		//hxfx.core.NodeBase.debug = true; // Debug

		stage.settings.bgColor = kha.Color.White;

		bordered = new BorderContainer();

        // Fill some space
		bordered.settings.width = LayoutSize.Percent(50);
		bordered.settings.height = Percent(50);
		bordered.settings.alignX = PercentLT(20);
		bordered.settings.alignY = PercentLT(20);

        bordered.settings.bgColor = kha.Color.fromFloats(.8,.8,.8,1);

        bordered.borderContainerSettings.borderColor = kha.Color.Black;
        bordered.borderContainerSettings.borderWidth = 4;
		bordered.borderContainerSettings.borderCornerRadius = 15;

		bordered.borderContainerSettings.resizeable = true;

		textField = new TextField();
		textField.text = "some random crap some random crap some random crap some random crap";
		textField.settings.color = kha.Color.Black;
		textField.fontSettings.fontSize = 24;
		textField.settings.width=Percent(100);
		textField.settings.height=Percent(100);
		textField.settings.alignX=FixedLT(5);
		textField.settings.alignY=FixedLT(5);
		textField.fontSettings.wordWrap = true;
		textField.parent = bordered.viewport;

		bordered.parent = stage;

		//kha.Scheduler.addTimeTask(randomRadiusChange, 0, .02);
		//kha.Scheduler.addTimeTask(randomWidthChange, 0, .05);

		kha.Assets.loadFont("arial", function(arial:kha.Font)
		{
			textField.fontSettings.font = arial;
		});
	}

	var incDec:Float = .25;
	public function randomRadiusChange() {
		//bordered.borderContainerSettings.borderCornerRadius = Std.random(50);
		bordered.borderContainerSettings.borderCornerRadius += incDec;
		if(bordered.borderContainerSettings.borderCornerRadius > 50 || bordered.borderContainerSettings.borderCornerRadius <= 1) incDec *=-1;
		//if(bordered.borderContainerSettings.borderCornerRadius >= bordered.borderContainerSettings.borderWidth || bordered.borderContainerSettings.borderCornerRadius < 0) incDec *=-1;
	}

	var bincDec:Float = .25;
	public function randomWidthChange() {
		//bordered.borderContainerSettings.borderCornerRadius = Std.random(50);
		bordered.borderContainerSettings.borderWidth += bincDec;
		if(bordered.borderContainerSettings.borderWidth > 30 || bordered.borderContainerSettings.borderWidth <= 1) bincDec *=-1;
	}
}