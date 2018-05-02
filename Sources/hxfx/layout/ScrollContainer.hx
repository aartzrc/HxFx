package hxfx.layout;

import hxfx.core.NodeBase;

@:bindable
class ScrollContainer extends GridContainer {

    public static inline var scrollBarWidth = 20;
    var vScroll:ScrollBar;
    var hScroll:ScrollBar;
    var cornerCell:NodeBase;
    public var viewportCell:NodeBase;

    public var viewport:AbsoluteContainer;
    public var viewportPosition:Position;
    
    
    public function new() {
		super(2,2, new ScrollContainerSettings()); // Create a 2x2 grid with default settings

        viewportCell = getCell(0,0);
		viewportCell.settings.alignX = FixedLT(0);
		viewportCell.settings.alignY = FixedLT(0);

		viewport = new AbsoluteContainer();
		viewport.settings.width = Percent(100);
		viewport.settings.height = Percent(100);

        viewportPosition = new Position({x: 0, y:0 });
        viewport.settings.alignX = FixedLT(viewportPosition.x);
		viewport.settings.alignY = FixedLT(viewportPosition.y);
        Bind.bind(viewportPosition.x, updateScrollPosition);
        Bind.bind(viewportPosition.y, updateScrollPosition);
        
        viewport.settings.fitToChildren = true; // Grow viewport as needed to fit all children - this is how scroll size/position is determined

		viewport.parent = viewportCell; // Attach to the center
        viewportCell.settings.overflowHidden = true; // Scissor any viewport overflow

        // Create the scroll bars
        vScroll = new ScrollBar(this, Vertical);
        Bind.bind(vScroll.pos, updateViewportPosition);
		hScroll = new ScrollBar(this, Horizontal);
        Bind.bind(hScroll.pos, updateViewportPosition);

        // Lower right corner
        cornerCell = getCell(1,1);
        cornerCell.settings.alignX = PercentRB(100);
        cornerCell.settings.alignY = PercentRB(100);
		
		setChildIndex(viewportCell, _childNodes.length-1); // Make the viewport render last

        Bind.bind(vScroll.size.w, updateCorner);
        Bind.bind(hScroll.size.h, updateCorner);
    }

    public function updateScrollPosition(from:Float, to:Float) {
        vScroll.pos = -viewportPosition.y;
        hScroll.pos = -viewportPosition.x;
    }

    public function updateViewportPosition(from:Float, to:Float) {
        viewportPosition.y = -vScroll.pos;
        viewportPosition.x = -hScroll.pos;
        viewport.settings.alignX = FixedLT(viewportPosition.x);
		viewport.settings.alignY = FixedLT(viewportPosition.y);
    }

	public var scrollContainerSettings(get,never):ScrollContainerSettings;

	public function get_scrollContainerSettings() {
		return cast settings;
	}

    public function updateCorner(from:Float, to:Float) {
        cornerCell.settings.height = Fixed(hScroll.size.h);
        cornerCell.settings.width = Fixed(vScroll.size.w);
        vScroll.parent.settings.height = PercentLessFixed(100, hScroll.size.h);
        hScroll.parent.settings.width = PercentLessFixed(100, vScroll.size.w);
        viewportCell.settings.width = PercentLessFixed(100, vScroll.size.w);
		viewportCell.settings.height = PercentLessFixed(100, hScroll.size.h);
    }
}

@:bindable
class ScrollContainerSettings extends NodeBaseSettings implements IBindable {
	public var scrollHorizontal:ScrollBarShow = OnDemand;
    public var scrollVertical:ScrollBarShow = OnDemand;
}

enum ScrollBarShow {
    Never;
    OnDemand;
    Always;
}

// TODO: Move this to components
@:bindable
class ScrollBar extends NodeBase {
    var orientation:Orientation;
    var container:ScrollContainer;

    //var lessArrow:AbsoluteContainer = new AbsoluteContainer();
    var lessArrow:BorderContainer = new BorderContainer();
    //var moreArrow:AbsoluteContainer = new AbsoluteContainer();
    var moreArrow:BorderContainer = new BorderContainer();
    var sliderFill:AbsoluteContainer = new AbsoluteContainer();
    //public var slider:AbsoluteContainer = new AbsoluteContainer();
    public var slider:BorderContainer = new BorderContainer();

    public var min:Float = 0;
    public var max:Float = 0;
    public var pos:Float = 0;
    public var scrollSpeed:Float = 10;

    public function new(container:ScrollContainer, orientation:Orientation) {
		super();
        this.orientation = orientation;
		this.container = container;

		_init();
	}

    function _init() {
		switch(orientation) {
			case Vertical:
				// Fill parent width, stick to right side
				settings.width = Percent(100);
                settings.alignX = PercentRB(100);

                // 100% height, float to middle
                settings.height = Percent(100);
				settings.alignY = PercentM(50);

				// Attach to the right top cell
				parent = container.getCell(1,0);

				// Tell my parent to stay at the top
				parent.settings.alignX = PercentRB(100);
				parent.settings.alignY = FixedLT(0);

                // Full height, fixed width
                parent.settings.height = Percent(100);
                // TODO: Setting Fixed(0) doesn't work! Grid reverts to default size
                parent.settings.width = Fixed(0); // Hide scroll bar by default - showHideScrollBar will adjust

                // Up arrow
                lessArrow.settings.width = Percent(100);
                lessArrow.settings.height = Fixed(ScrollContainer.scrollBarWidth);
                lessArrow.settings.alignX = PercentLT(0);
                lessArrow.settings.alignY = PercentLT(0);
                
                // Down arrow
                moreArrow.settings.width = Percent(100);
                moreArrow.settings.height = Fixed(ScrollContainer.scrollBarWidth);
                moreArrow.settings.alignX = PercentRB(100);
                moreArrow.settings.alignY = PercentRB(100);

                // Fill
                sliderFill.settings.width = Percent(100);
                sliderFill.settings.height = PercentLessFixed(100, ScrollContainer.scrollBarWidth*2);
                sliderFill.settings.alignX = PercentLT(0);
                sliderFill.settings.alignY = PercentM(50);

                // Slider box
                slider.settings.width = Percent(100);
                slider.settings.height = Fixed(ScrollContainer.scrollBarWidth); // TODO: this should adjust based on visible space
                slider.settings.alignX = PercentLT(0);
                slider.settings.alignY = FixedLT(0);

                Bind.bind(container.scrollContainerSettings.scrollVertical, showHideScrollBar);
                showHideScrollBar(Never, container.scrollContainerSettings.scrollVertical);
            case Horizontal:
                // Fill parent height, stick to bottom
				settings.height = Percent(100);
                settings.alignY = PercentRB(100);

                // 100% width, float to middle
                settings.width = Percent(100);
				settings.alignX = PercentM(50);

				// Attach to the bottom left cell
				parent = container.getCell(0,1);

				// Tell my parent to stay to the left
				parent.settings.alignY = PercentRB(100);
				parent.settings.alignX = FixedLT(0);

                // Full width, fixed height
                parent.settings.width = Percent(100);
                // TODO: Setting Fixed(0) doesn't work! Grid reverts to default size
                parent.settings.height = Fixed(0); // Hide scroll bar by default - showHideScrollBar will adjust
                
                // Left arrow
                lessArrow.settings.width = Fixed(ScrollContainer.scrollBarWidth);
                lessArrow.settings.height = Percent(100);
                lessArrow.settings.alignX = PercentLT(0);
                lessArrow.settings.alignY = PercentLT(0);

                // Right arrow
                moreArrow.settings.width = Fixed(ScrollContainer.scrollBarWidth);
                moreArrow.settings.height = Percent(100);
                moreArrow.settings.alignX = PercentRB(100);
                moreArrow.settings.alignY = PercentRB(100);

                // Fill
                sliderFill.settings.height = Percent(100);
                sliderFill.settings.width = PercentLessFixed(100, ScrollContainer.scrollBarWidth*2);
                sliderFill.settings.alignX = PercentM(50);
                sliderFill.settings.alignY = PercentLT(0);

                // Slider box
                slider.settings.width = Fixed(ScrollContainer.scrollBarWidth); // TODO: this should adjust based on visible space
                slider.settings.height = Percent(100);
                slider.settings.alignX = FixedLT(0);
                slider.settings.alignY = PercentLT(0);

                Bind.bind(container.scrollContainerSettings.scrollHorizontal, showHideScrollBar);
                showHideScrollBar(Never, container.scrollContainerSettings.scrollHorizontal);
        }

        // Do some background so we can see
        //settings.bgColor = kha.Color.Green;

        lessArrow.settings.bgColor = kha.Color.fromFloats(0,0,0,.4);
        lessArrow.borderContainerSettings.borderColor = kha.Color.Black;
        lessArrow.mouseSubscribe = true;
        lessArrow.parent = this;

        moreArrow.settings.bgColor = kha.Color.fromFloats(0,0,0,.4);
        moreArrow.borderContainerSettings.borderColor = kha.Color.Black;
        moreArrow.mouseSubscribe = true;
        moreArrow.parent = this;

        sliderFill.settings.bgColor = kha.Color.fromFloats(0,0,0,.1);
        sliderFill.mouseSubscribe = true;
        sliderFill.parent = this;

        slider.borderContainerSettings.borderColor = kha.Color.Black;
        slider.settings.bgColor = kha.Color.fromFloats(0,0,0,.2);
        slider.mouseSubscribe = true;
        slider.parent = sliderFill;
        Bind.bind(slider.mouseData.b1down, _toggleDrag);

        Bind.bind(lessArrow.mouseData.b1down, _lessMouseDown);
        Bind.bind(moreArrow.mouseData.b1down, _moreMouseDown);
    }

    function _toggleDrag(from:Bool, to:Bool) {
        if(to && slider.mouseData.mouseInBounds) {
            switch(orientation) {
                case Vertical:
                    if(startSliderPos == null) {
                        startSliderPos = sliderFill.mouseData.y;
                        startScrollPos = pos;
                    }
                    Bind.bind(sliderFill.mouseData.y, _handleDrag);
                case Horizontal:
                    if(startSliderPos == null) {
                        startSliderPos = sliderFill.mouseData.x;
                        startScrollPos = pos;
                    }
                    Bind.bind(sliderFill.mouseData.x, _handleDrag);
            }
        } else {
            switch(orientation) {
                case Vertical:
                    Bind.unbind(sliderFill.mouseData.y, _handleDrag);
                case Horizontal:
                    Bind.unbind(sliderFill.mouseData.x, _handleDrag);
            }

            if(!to) {
                startSliderPos = null;
            }
        }
    }

    var startSliderPos:Float;
    var startScrollPos:Float;
    function _handleDrag(from:Float, to:Float) {
        switch(orientation) {
                case Vertical:
                    // How far should slider move to match mouse
                    var destY = startSliderPos - sliderFill.mouseData.y;
                    // How should viewport pos move?
                    var pixelRange = (sliderFill.size.h - slider.size.h);
                    var posRange = (max-min);
                    var ratio = posRange/ pixelRange;
                    var newPos = destY * -ratio + startScrollPos;
                    if(newPos<min) newPos = min;
                    if(newPos>max) newPos = max;
                    pos=newPos;
                    // TODO: Wow.. that's a mess - rethink this
                case Horizontal:
                    // How far should slider move to match mouse
                    var destX = startSliderPos - sliderFill.mouseData.x;
                    // How should viewport pos move?
                    var pixelRange = (sliderFill.size.w - slider.size.w);
                    var posRange = (max-min);
                    var ratio = posRange/ pixelRange;
                    var newPos = destX * -ratio + startScrollPos;
                    if(newPos<min) newPos = min;
                    if(newPos>max) newPos = max;
                    pos=newPos;
            }
    }

    function showHideScrollBar(from:ScrollBarShow, to:ScrollBarShow) {
        switch(orientation) {
            case Vertical:
                switch(container.scrollContainerSettings.scrollVertical) {
                    case Always:
                        parent.settings.width = Fixed(ScrollContainer.scrollBarWidth);
                        Bind.bind(container.viewport.size.h, updateScrollbar);
                    case OnDemand:
                        parent.settings.width = Fixed(0); // Hide scroll bar
                        Bind.bind(container.viewport.size.h, updateScrollbar);
                    case Never:
                        parent.settings.width = Fixed(0); // Hide scroll bar
                        Bind.unbind(container.viewport.size.h, updateScrollbar);
                }
            case Horizontal:
                switch(container.scrollContainerSettings.scrollHorizontal) {
                    case Always:
                        parent.settings.height = Fixed(ScrollContainer.scrollBarWidth);
                        Bind.bind(container.viewport.size.w, updateScrollbar);
                    case OnDemand:
                        parent.settings.height = Fixed(0); // Hide scroll bar
                        Bind.bind(container.viewport.size.w, updateScrollbar);
                    case Never:
                        parent.settings.height = Fixed(0); // Hide scroll bar
                        Bind.unbind(container.viewport.size.w, updateScrollbar);
                }
        }
    }

    function updateScrollbar(from:Float, to:Float) {
        //trace(container.viewport.size);
        //trace(container.viewportCell.scissorSize);

        switch(orientation) {
            case Vertical:
                switch(container.scrollContainerSettings.scrollVertical) {
                    case Always:
                        // Update range
                    case OnDemand:
                        // Show/hide check
                        if(container.viewport.size.h > container.viewportCell.scissorSize.h) {
                            // Show scrollbar
                            parent.settings.width = Fixed(ScrollContainer.scrollBarWidth);
                            
                            // Adjust slider
                            max = container.viewport.size.h - container.viewportCell.scissorSize.h;
                            slider.settings.height = Percent((container.viewportCell.scissorSize.h / container.viewport.size.h)*100);
                            slider.settings.alignY = PercentLTLessFixed((pos/(max-min))*100, slider.size.h);
                        } else {
                            // Hide scrollbar
                            parent.settings.width = Fixed(0); // Hide scroll bar
                        }
                    case Never:
                        // Nothing
                }
            case Horizontal:
                switch(container.scrollContainerSettings.scrollHorizontal) {
                    case Always:
                        // Update range
                    case OnDemand:
                        // Show/hide check
                        if(container.viewport.size.w > container.viewportCell.scissorSize.w) {
                            // Show scrollbar
                            parent.settings.height = Fixed(ScrollContainer.scrollBarWidth);

                            // Adjust slider
                            max = container.viewport.size.w - container.viewportCell.scissorSize.w;
                            slider.settings.width = Percent((container.viewportCell.scissorSize.w / container.viewport.size.w)*100);
                            slider.settings.alignX = PercentLTLessFixed((pos/(max-min))*100, slider.size.w);
                        } else {
                            // Hide scrollbar
                            parent.settings.height = Fixed(0); // Hide scroll bar
                        }
                    case Never:
                        // Nothing
                }
        }
    }

    function _lessMouseDown(from:Bool, to:Bool) {
        if(lessArrow.mouseData.mouseInBounds) {
            var newPos = pos - scrollSpeed;
            if(newPos < min) newPos = min;
            pos = newPos;
        }
    }

    function _moreMouseDown(from:Bool, to:Bool) {
        if(moreArrow.mouseData.mouseInBounds) {
            var newPos = pos + scrollSpeed;
            if(newPos > max) newPos = max;
            pos = newPos;
        }
    }
}

enum Orientation {
	Horizontal;
	Vertical;
}