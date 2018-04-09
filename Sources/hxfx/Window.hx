package hxfx;

import kha.input.Mouse;

/**
Starting point of a HAF application, create or extend this class to begin
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

	public function new(appTitle:String) {
		windowSize = new Size({ width: 1024, height: 768 });

		// Default options
		var windowModeOptions:WindowedModeOptions = {
			resizable: true,
			maximizable: true, 
			minimizable: true
		};

		var rendererOptions:RendererOptions = {
			//depthStencilFormat: DepthStencilFormat.DepthAutoStencilAuto
			//samplesPerPixel:1 // TODO: make sure antialias setting gets pushed into Kha-windows
		};

		var windowOptions:WindowOptions = {
			width : cast windowSize.width,
			height : cast windowSize.height,
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
		// Create the stage
		stage = new Stage(this);

		// Load assets?

		// Set up callbacks
        // TODO: Application state doesn't always work, probably per-target issues
        System.notifyOnApplicationState(onForeground, onResume, onPause, onBackground, onShutdown);
		System.notifyOnResize(onResize);
		System.notifyOnRender(render);
		initialized = true;

		// Begin rendering
		System.renderNextFrame = true;
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

		mouse = new hxfx.core.data.Mouse(windowId);
	}

	public function onResize() {
		windowSize.width = System.windowWidth(windowId);
		windowSize.height = System.windowHeight(windowId);
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

}