package hxfx;

import kha.input.Mouse;
import kha.input.Keyboard;
#if js
import js.Browser;
#end

/**
Starting point of a HxFx application, create or extend this class to begin
Window provides an interface between Kha (hardware access) and the Stage (root level display)
All components are attached to the Stage scene graph and updates happen based on bindings (bindx2)
**/
@:bindable
class Window implements IBindable {
	var windowId:Int = -1;
	var initialized:Bool = false;
	var stage:Stage;
	public var windowSize:Size;
	public var mouse:hxfx.core.data.Mouse;
	public var keyboard:hxfx.core.data.Keyboard;

	public var antialias:Int = 4;

	public function new(appTitle:String) {
		windowSize = new Size({ w: 1024, h: 768 });

		// Default options
		var windowModeOptions:WindowedModeOptions = {
			resizable: true,
			maximizable: true, 
			minimizable: true,
		};

		var rendererOptions:RendererOptions = {
			//depthStencilFormat: DepthStencilFormat.DepthAutoStencilAuto
			samplesPerPixel:this.antialias // TODO: make sure antialias setting gets pushed into Kha-windows
		};

		var windowOptions:WindowOptions = {
			width : cast windowSize.w,
			height : cast windowSize.h,
			mode : WindowMode.Window,
			title : appTitle,
			windowedModeOptions : windowModeOptions,
			rendererOptions : rendererOptions
		};

		// TODO: kha.init creates all windows in one shot, need to break this up so new windows can be created on demand
		// Windows/OSX target would create real window, HTML5 target would create a new canvas
		System.initEx(appTitle, [windowOptions], windowCallback, onInit);
	}

	private function onInit() {
		// Create the stage - fill all available window space
		stage = new Stage(this);
		stage.settings.width = Percent(100);
		stage.settings.height = Percent(100);

#if debug
		mouse = new hxfx.core.data.Mouse(windowId);
		keyboard = new hxfx.core.data.Keyboard();
#end
		// Load assets?

		// Set up callbacks
        // TODO: Application state doesn't always work, probably per-target issues
        System.notifyOnApplicationState(onForeground, onResume, onPause, onBackground, onShutdown);
		System.notifyOnResize(onResize);
		System.notifyOnRender(render);
		windowSize.w = System._windowWidth;
		windowSize.h = System._windowHeight;
		initialized = true;

		// Begin layout and render
		stage.layoutIsValid = false;
    }

	public function render(framebuffer: Framebuffer): Void {
		// Pause render task - once started it will run forever
		System.renderNextFrame = false;

		// Kha render calls back to here
		var g2 = framebuffer.g2;

		g2.begin(false);

		stage.render(g2);

		g2.end();
	}

	public function windowCallback(winId:Int) {
        windowId = winId;
#if !debug
		mouse = new hxfx.core.data.Mouse(windowId);
		keyboard = new hxfx.core.data.Keyboard();
#end
	}

	public function onResize(width:Int, height:Int) {
		//windowSize.width = System.windowWidth(windowId);
		//windowSize.height = System.windowHeight(windowId);
		windowSize.w = width;
		windowSize.h = height;
    }

	public function onForeground() {
        trace("Foreground");
    }

    public function onResume() {
        trace("Resume");
    }

    public function onPause() {
        trace("Pause");
    }

    public function onBackground() {
        trace("Background");
    }

    public function onShutdown() {
        trace("Shutdown");
    }

	//var cursorStack:List<String> = new List<String>();

	public function setCursor(cursorName:String) {
		/*var useCursorName:String = null;
		
		if(cursorName == null) {
			cursorStack.pop();
		} else {
			cursorStack.push(cursorName);
		}

		// Grab the current cursor from the stack
		if(cursorStack.length>0) {
			useCursorName = cursorStack.first();
		}*/

		// Cursor change needs to be handled per target, maybe push in to Kha?
		#if js
		js.Browser.window.document.getElementsByTagName("canvas")[0].style.cursor = cursorName;
		#end
	}

}