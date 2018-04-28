package hxfx.layout;

import hxfx.core.NodeBase;

@:bindable
class ScrollContainer extends GridContainer {

    public static inline var scrollBarWidth = 20;
    var vScroll:ScrollBar;
    var hScroll:ScrollBar;

    public var viewport:AbsoluteContainer;
    var viewportCell:NodeBase;
    
    public function new() {
		super(2,2, new ScrollContainerSettings()); // Create a 2x2 grid with default settings

        vScroll = new ScrollBar(this, Vertical);
		hScroll = new ScrollBar(this, Horizontal);

        viewportCell = getCell(0,0);
		viewportCell.settings.width = PercentLessFixed(100, ScrollContainer.scrollBarWidth);
		viewportCell.settings.height = PercentLessFixed(100, ScrollContainer.scrollBarWidth);
		viewportCell.settings.alignX = FixedLT(0);
		viewportCell.settings.alignY = FixedLT(0);

		viewport = new AbsoluteContainer();
		viewport.settings.width = Percent(100);
		viewport.settings.height = Percent(100);
		viewport.settings.alignX = PercentM(50);
		viewport.settings.alignY = PercentM(50);

		viewport.parent = viewportCell; // Attach to the center

        // Lower right corner
        var corner = getCell(1,1);
        corner.settings.alignX = PercentRB(100);
        corner.settings.alignY = PercentRB(100);
		
		setChildIndex(viewportCell, _childNodes.length-1); // Make the viewport render last
    }

	public var scrollContainerSettings(get,never):ScrollContainerSettings;

	public function get_scrollContainerSettings() {
		return cast settings;
	}

    public function updateCorner() {
		if(scrollContainerSettings.scrollHorizontal) {
            getCell(1,1).settings.height = Fixed(ScrollContainer.scrollBarWidth);
        }
        if(scrollContainerSettings.scrollVertical) {
            getCell(1,1).settings.width = Fixed(ScrollContainer.scrollBarWidth);
        }
    }
}

@:bindable
class ScrollContainerSettings extends NodeBaseSettings implements IBindable {
	public var scrollHorizontal:Bool = true;
    public var scrollVertical:Bool = true;
}

// TODO: Move this to components
@:bindable
class ScrollBar extends NodeBase {
    var orientation:Orientation;
    var container:ScrollContainer;

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

				// Tell my parent to stay in the right middle
				parent.settings.alignX = PercentRB(100);
				parent.settings.alignY = PercentM(50);

                // Full height, fixed 20px width
                parent.settings.height = Percent(100);
                if(container.scrollContainerSettings.scrollVertical) {
				    parent.settings.width = Fixed(ScrollContainer.scrollBarWidth);
                } else {
                    parent.settings.width = Fixed(0); // Hide scroll bar
                }

                Bind.bind(container.scrollContainerSettings.scrollVertical, showHideScrollBar);
            case Horizontal:
                // Fill parent height, stick to bottom
				settings.height = Percent(100);
                settings.alignY = PercentRB(100);

                // 100% width, float to middle
                settings.width = Percent(100);
				settings.alignX = PercentM(50);

				// Attach to the bottom left cell
				parent = container.getCell(0,1);

				// Tell my parent to stay in the bottom middle
				parent.settings.alignY = PercentRB(100);
				parent.settings.alignX = PercentM(50);

                // Full width, fixed 20px height
                parent.settings.width = Percent(100);
                if(container.scrollContainerSettings.scrollHorizontal) {
				    parent.settings.height = Fixed(ScrollContainer.scrollBarWidth);
                } else {
                    parent.settings.height = Fixed(0); // Hide scroll bar
                }
                Bind.bind(container.scrollContainerSettings.scrollVertical, showHideScrollBar);
        }
    }

    function showHideScrollBar(from:Bool, to:Bool) {
        trace("here");
        switch(orientation) {
            case Vertical:
                if(container.scrollContainerSettings.scrollVertical) {
				    parent.settings.width = Fixed(ScrollContainer.scrollBarWidth);
                } else {
                    parent.settings.width = Fixed(0); // Hide scroll bar
                }
            case Horizontal:
                if(container.scrollContainerSettings.scrollHorizontal) {
				    parent.settings.height = Fixed(ScrollContainer.scrollBarWidth);
                } else {
                    parent.settings.height = Fixed(0); // Hide scroll bar
                }
        }

        container.updateCorner();
    }
}

enum Orientation {
	Horizontal;
	Vertical;
}