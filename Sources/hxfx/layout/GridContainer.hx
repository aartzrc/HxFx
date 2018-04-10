package hxfx.layout;

import hxfx.core.NodeBase;

/**
A fixed grid, specify x and y columns and it will space out evenly
**/
@:bindable
class GridContainer extends NodeBase {
	
	var _xColCount:Int = 1;
	var _yColCount:Int = 1;
	var _gridNodes:Array<AbsoluteContainer> = [];
	public var gridNodeColorEven:Color = Color.Transparent;
	public var gridNodeColorOdd:Color = Color.Transparent;

	public function new(xColumns:Int, yColumns:Int) {
		super();

		_xColCount = xColumns;
		_yColCount = yColumns;

		// Set up default grid
		for(x in 0 ... _xColCount) {
			for( y in 0 ... _yColCount) {
				setChild(null, x, y);
			}
		}

		backgroundColor = Color.Transparent;

		Bind.bind(this.gridNodeColorEven, changeGridNodeColors);
		Bind.bind(this.gridNodeColorOdd, changeGridNodeColors);
	}

	private function changeGridNodeColors(from:Color, to:Color) {
		// Update grid colors
		for(x in 0 ... _xColCount) {
			for( y in 0 ... _yColCount) {
				var index = (y * _xColCount) + x;
				var xMod = x % 2;
				var yMod = y % 2;
				var fMod = (xMod+yMod) % 2;
				if(fMod == 1) {
					_gridNodes[index].backgroundColor = gridNodeColorOdd;
				} else {
					_gridNodes[index].backgroundColor = gridNodeColorEven;
				}
			}
		}

		System.renderNextFrame = true;
	}

	public function getChild(x:Int, y:Int):NodeBase {
		if(x>=0 && x<_xColCount && y>=0 && y<_yColCount) {
			var index = (y * _xColCount) + x;
			return _gridNodes[index];
		}
		return null;
	}

	public function setChild(child:NodeBase, x:Int, y:Int) {
		if(x>=0 && x<_xColCount && y>=0 && y<_yColCount) {
			// Keep track of containers
			var index = (y * _xColCount) + x;
			var gridNode:AbsoluteContainer = null;
			if(_gridNodes[index] != null) {
				gridNode = _gridNodes[index];
			} else {
				// Create an AbsoluteContainer that fills the grid block
				gridNode = new AbsoluteContainer();
				_gridNodes[index] = gridNode;
				gridNode.layout.widthPercent = (100/_xColCount);
				gridNode.layout.heightPercent = (100/_yColCount);
				gridNode.layout.marginLeftPercent = gridNode.layout.widthPercent * x;
				gridNode.layout.marginTopPercent = gridNode.layout.heightPercent * y;
				// Debug test, flip background colors of the grid
				var xMod = x % 2;
				var yMod = y % 2;
				var fMod = (xMod+yMod) % 2;
				if(fMod == 1) {
					gridNode.backgroundColor = gridNodeColorOdd;
				} else {
					gridNode.backgroundColor = gridNodeColorEven;
				}
				gridNode.parent = this;
			}
			
			// Assign the child to this grid block (the child will see the AbsoluteContainer and adjust as needed)-
			if(child != null) {
				child.parent = gridNode;
			}

			// TODO: invalidate grid rectangle, can child handle that based on parent? if child handles then it can tell render engine it's previous rect and new rect at the same time
		}
	}
}