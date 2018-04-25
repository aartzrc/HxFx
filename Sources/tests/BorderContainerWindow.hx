package tests;

import hxfx.Window;
import hxfx.layout.*;

class BorderContainerWindow extends Window {

	public static function main() {
		new BorderContainerWindow("HxFx Test - BorderContainerWindow");
	}

	var bordered:BorderContainer;

	override function onInit() {
		super.onInit();

		//hxfx.core.NodeBase.debug = true; // Debug

		stage.settings.bgColor = kha.Color.White;

		bordered = new BorderContainer();

        // Fill some space
		bordered.settings.width = LayoutSize.Percent(50);
		bordered.settings.height = Percent(50);

        bordered.settings.bgColor = kha.Color.fromFloats(.8,.8,.8,1);

        bordered.borderContainerSettings.borderColor = kha.Color.Black;
        bordered.borderContainerSettings.borderWidth = 2;
		bordered.borderContainerSettings.borderCornerRadius = 6;

        /*var arc = new ArcQuadrant();
        arc.setArcRule(Radius(50));
        arc.setArcRule(Width(5));
        arc.setLayoutRule(Color(kha.Color.Black));
        arc.setLayoutRule(BackgroundColor(kha.Color.White));
        arc.parent = bordered.viewport;*/

		bordered.parent = stage;

		//kha.Scheduler.addTimeTask(randomRadiusChange, 0, .02);
		//kha.Scheduler.addTimeTask(randomWidthChange, 0, .05);
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