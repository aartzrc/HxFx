package hxfx.layout;

import hxfx.core.NodeBase;

/**
A variable grid, specify x and y columns and it will space out evenly be default
Use setGridRule to change column/row proportions
**/
@:bindable
class GridContainer extends AbsoluteContainer {
	
	var _xColCount:Int;
	var _yColCount:Int;
	var _gridNodes:Array<NodeBase> = [];

	public function new(xColumns:Int, yColumns:Int) {
		super();

		_xColCount = xColumns;
		_yColCount = yColumns;

		// Set up default the grid cells
		for(x in 0 ... _xColCount) {
			for(y in 0 ... _yColCount) {
				setCell(null, x, y);
			}
		}
	}

	/**
	 *  Helper to set all child nodes in a column
	 *  @param col - 
	 *  @param rule - 
	 */
	public function setColumnLayoutRule(col:Int, rule:BaseRule) {
		for(y in 0 ... _yColCount) {
			getCell(col, y).setLayoutRule(rule);
		}
	}

	/**
	 *  Helper to set all child nodes in a row
	 *  @param row - 
	 *  @param rule - 
	 */
	public function setRowLayoutRule(row:Int, rule:BaseRule) {
		for(x in 0 ... _xColCount) {
			getCell(x, row).setLayoutRule(rule);
		}
	}

	public function getCell(x:Int, y:Int):NodeBase {
		if(x>=0 && x<_xColCount && y>=0 && y<_yColCount) {
			var index = (y * _xColCount) + x;
			return _gridNodes[index];
		}
		return null;
	}

	public function setCell(cell:NodeBase, x:Int, y:Int) {
		var w:Float = 100/_xColCount;
		var h:Float = 100/_yColCount;
		if(x>=0 && x<_xColCount && y>=0 && y<_yColCount) {
			// Keep track of containers
			var index = (y * _xColCount) + x;
			if(_gridNodes[index] != null) {
				_gridNodes[index].parent = null; // Detach previous cell from parent
			}
			if(cell == null) {
				// By default create an AbsoluteContainer that fills the grid block
				cell = new AbsoluteContainer();
				cell.setLayoutRule(BaseRule.Width(LayoutSize.Percent(w)));
				cell.setLayoutRule(BaseRule.Height(LayoutSize.Percent(h)));
				cell.setLayoutRule(BaseRule.AlignX(Align.PercentLT(w * x)));
				cell.setLayoutRule(BaseRule.AlignY(Align.PercentLT(h * y)));

				// Debug test, flip background colors of the grid
				/*var xMod = x % 2;
				var yMod = y % 2;
				var fMod = (xMod+yMod) % 2;
				if(fMod == 1) {
					gridNode.setLayoutRule(BaseRule.BackgroundColor(kha.Color.fromFloats(0,0,0,.3)));
				} else {
					gridNode.setLayoutRule(BaseRule.BackgroundColor(kha.Color.fromFloats(0,0,0,.1)));
				}*/
			}
			_gridNodes[index] = cell;
			cell.parent = this;
			
			// Assign the child to this grid block (the child will see the AbsoluteContainer and adjust as needed)-
			/*if(child != null) {
				child.parent = gridNode;
				trace(gridNode._childNodes.length);
			}*/
		}
	}
}
