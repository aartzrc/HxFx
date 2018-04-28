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
    
    
    public function new() {
		super(2,2, new ScrollContainerSettings()); // Create a 2x2 grid with default settings

        viewportCell = getCell(0,0);
		viewportCell.settings.alignX = FixedLT(0);
		viewportCell.settings.alignY = FixedLT(0);

		viewport = new AbsoluteContainer();
		viewport.settings.width = Percent(100);
		viewport.settings.height = Percent(100);
		viewport.settings.alignX = FixedLT(0); //PercentM(50);
		viewport.settings.alignY = FixedLT(0); //PercentM(50);
        viewport.settings.fitToChildren = true; // Grow viewport as needed to fit all children - this is how scroll size/position is determined

		viewport.parent = viewportCell; // Attach to the center
        viewport.settings.overflowHidden = true; // Scissor any viewport overflow

        // Create the scroll bars
        vScroll = new ScrollBar(this, Vertical);
		hScroll = new ScrollBar(this, Horizontal);

        // Lower right corner
        cornerCell = getCell(1,1);
        cornerCell.settings.alignX = PercentRB(100);
        cornerCell.settings.alignY = PercentRB(100);
		
		setChildIndex(viewportCell, _childNodes.length-1); // Make the viewport render last

        Bind.bind(vScroll.size.w, updateCorner);
        Bind.bind(hScroll.size.h, updateCorner);
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

    var lessArrow:AbsoluteContainer = new AbsoluteContainer();
    var moreArrow:AbsoluteContainer = new AbsoluteContainer();
    var sliderFill:AbsoluteContainer = new AbsoluteContainer();
    var slider:AbsoluteContainer = new AbsoluteContainer();

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

                // Do some background so we can see
                settings.bgColor = kha.Color.Green;

				// Attach to the right top cell
				parent = container.getCell(1,0);

				// Tell my parent to stay at the top
				parent.settings.alignX = PercentRB(100);
				parent.settings.alignY = FixedLT(0);

                // Full height, fixed width
                parent.settings.height = Percent(100);
                // TODO: Setting Fixed(0) doesn't work! Grid reverts to default size
                parent.settings.width = Fixed(.01); // Hide scroll bar by default - showHideScrollBar will adjust

                // Up arrow
                lessArrow.settings.width = Percent(100);
                lessArrow.settings.height = Fixed(ScrollContainer.scrollBarWidth);
                lessArrow.settings.alignX = PercentLT(0);
                lessArrow.settings.alignY = PercentLT(0);
                lessArrow.settings.bgColor = kha.Color.Blue;
                lessArrow.parent = this;

                // Down arrow
                moreArrow.settings.width = Percent(100);
                moreArrow.settings.height = Fixed(ScrollContainer.scrollBarWidth);
                moreArrow.settings.alignX = PercentRB(100);
                moreArrow.settings.alignY = PercentRB(100);
                moreArrow.settings.bgColor = kha.Color.Blue;
                moreArrow.parent = this;

                Bind.bind(container.scrollContainerSettings.scrollVertical, showHideScrollBar);
                showHideScrollBar(Never, container.scrollContainerSettings.scrollVertical);
            case Horizontal:
                // Fill parent height, stick to bottom
				settings.height = Percent(100);
                settings.alignY = PercentRB(100);

                // 100% width, float to middle
                settings.width = Percent(100);
				settings.alignX = PercentM(50);

                // Do some background so we can see
                settings.bgColor = kha.Color.Green;

				// Attach to the bottom left cell
				parent = container.getCell(0,1);

				// Tell my parent to stay to the left
				parent.settings.alignY = PercentRB(100);
				parent.settings.alignX = FixedLT(0);

                // Full width, fixed height
                parent.settings.width = Percent(100);
                // TODO: Setting Fixed(0) doesn't work! Grid reverts to default size
                parent.settings.height = Fixed(.01); // Hide scroll bar by default - showHideScrollBar will adjust
                
                // Left arrow
                lessArrow.settings.width = Fixed(ScrollContainer.scrollBarWidth);
                lessArrow.settings.height = Percent(100);
                lessArrow.settings.alignX = PercentLT(0);
                lessArrow.settings.alignY = PercentLT(0);
                lessArrow.settings.bgColor = kha.Color.Blue;
                lessArrow.parent = this;

                // Right arrow
                moreArrow.settings.width = Fixed(ScrollContainer.scrollBarWidth);
                moreArrow.settings.height = Percent(100);
                moreArrow.settings.alignX = PercentRB(100);
                moreArrow.settings.alignY = PercentRB(100);
                moreArrow.settings.bgColor = kha.Color.Blue;
                moreArrow.parent = this;

                Bind.bind(container.scrollContainerSettings.scrollHorizontal, showHideScrollBar);
                showHideScrollBar(Never, container.scrollContainerSettings.scrollHorizontal);
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
                        parent.settings.width = Fixed(.01); // Hide scroll bar
                        Bind.bind(container.viewport.size.h, updateScrollbar);
                    case Never:
                        parent.settings.width = Fixed(.01); // Hide scroll bar
                        Bind.unbind(container.viewport.size.h, updateScrollbar);
                }
            case Horizontal:
                switch(container.scrollContainerSettings.scrollHorizontal) {
                    case Always:
                        parent.settings.height = Fixed(ScrollContainer.scrollBarWidth);
                        Bind.bind(container.viewport.size.w, updateScrollbar);
                    case OnDemand:
                        parent.settings.height = Fixed(.01); // Hide scroll bar
                        Bind.bind(container.viewport.size.w, updateScrollbar);
                    case Never:
                        parent.settings.height = Fixed(.01); // Hide scroll bar
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
                        } else {
                            // Hide scrollbar
                            parent.settings.width = Fixed(.01); // Hide scroll bar
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
                        } else {
                            // Hide scrollbar
                            parent.settings.height = Fixed(.01); // Hide scroll bar
                        }
                    case Never:
                        // Nothing
                }
        }
    }
}

enum Orientation {
	Horizontal;
	Vertical;
}