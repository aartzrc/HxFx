package tests;

import hxfx.Window;
import hxfx.layout.*;
import hxfx.component.TextField;

class BorderContainerWindow extends Window {
	public static function main() {
		new BorderContainerWindow("HxFx Test - BorderContainerWindow");
	}

	var bordered:BorderContainer;
	var textField:TextField;

	override function onInit() {
		super.onInit();

		//hxfx.core.NodeBase.debugLayout = true;
		//hxfx.core.NodeBase.debugHitbounds = true;

		stage.settings.bgColor = kha.Color.White;

		bordered = new BorderContainer();

        // Fill some space
		bordered.settings.width = Percent(50);
		bordered.settings.height = Percent(50);
		bordered.settings.alignX = PercentLT(20);
		bordered.settings.alignY = PercentLT(20);

        bordered.settings.bgColor = kha.Color.fromFloats(.8,.8,.8,1);

        bordered.borderContainerSettings.borderColor = kha.Color.Black;
        bordered.borderContainerSettings.borderWidth = 5;
		bordered.borderContainerSettings.borderCornerRadius = 12;

		bordered.borderContainerSettings.resizeable = true;

		textField = new TextField();
		textField.text = "Curabitur mattis mattis purus, at finibus enim feugiat id. Quisque odio turpis, pharetra id sapien ac, ullamcorper sodales sapien. Nulla id sapien mi. Sed nec metus consequat, imperdiet neque ac, dictum nisi. Etiam volutpat commodo tortor vitae sollicitudin. Morbi a arcu massa. Praesent malesuada elit sapien, et volutpat ipsum viverra sit amet. Suspendisse metus eros, vehicula a condimentum id, fermentum ut est. Ut ullamcorper sagittis facilisis. Vestibulum vestibulum, tellus in efficitur elementum, odio arcu volutpat turpis, non fringilla tellus enim vitae lacus. Donec eu fermentum eros. Donec ac lorem et nunc eleifend facilisis. Phasellus eget dignissim est. Nulla id sodales diam. Aenean ornare dignissim metus. Morbi consectetur eu lacus sit amet aliquam.";
		//textField.text = "asdf a ab Curabiasdftur, abc Curabitur";
		textField.settings.color = kha.Color.Black;
		textField.fontSettings.fontSize = 24;
		textField.settings.width=PercentLessFixed(100, 10);
		textField.settings.height=PercentLessFixed(100, 10);
		textField.settings.alignX=FixedLT(5);
		textField.settings.alignY=FixedLT(5);
		textField.fontSettings.wordWrap = true;
		textField.parent = bordered.viewport;

		bordered.parent = stage;

		//kha.Scheduler.addTimeTask(randomRadiusChange, 0, .1);
		//kha.Scheduler.addTimeTask(randomWidthChange, 0, .2);

		kha.Assets.loadFont("arial", function(arial:kha.Font)
		{
			textField.fontSettings.font = arial;
		});
	}

	var incDec:Float = 1;
	public function randomRadiusChange() {
		//bordered.borderContainerSettings.borderCornerRadius = Std.random(50);
		bordered.borderContainerSettings.borderCornerRadius += incDec;
		if(bordered.borderContainerSettings.borderCornerRadius > 50 || bordered.borderContainerSettings.borderCornerRadius <= 1) incDec *=-1;
		//if(bordered.borderContainerSettings.borderCornerRadius >= bordered.borderContainerSettings.borderWidth || bordered.borderContainerSettings.borderCornerRadius < 0) incDec *=-1;
	}

	var bincDec:Float = 1;
	public function randomWidthChange() {
		//bordered.borderContainerSettings.borderCornerRadius = Std.random(50);
		bordered.borderContainerSettings.borderWidth += bincDec;
		if(bordered.borderContainerSettings.borderWidth > 30 || bordered.borderContainerSettings.borderWidth <= 1) bincDec *=-1;
	}
}