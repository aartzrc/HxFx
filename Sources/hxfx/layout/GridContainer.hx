package hxfx.layout;

import hxfx.core.NodeBase;

/**
A variable grid, specify x and y columns and it will space out evenly be default
Use setGridRule to change column/row proportions
**/
@:bindable
class GridContainer extends AbsoluteContainer {
	
	public var columns(default, null):Int;
	public var rows(default, null):Int;
	var _gridNodes:Array<NodeBase> = [];

	public function new(columns:Int, rows:Int, ?useSettings:NodeBaseSettings) {
		super(useSettings);

		this.columns = columns;
		this.rows = rows;

		// Set up default the grid cells
		for(x in 0 ... columns) {
			for(y in 0 ... rows) {
				_initCell(null, x, y);
			}
		}
	}

	public function getRowCells(row:Int):Array<NodeBase> {
		var cells = new Array<NodeBase>();
		for(i in 0 ... columns) {
			cells.push(getCell(i, row));
		}
		return cells;
	}

	public function getColumnCells(column:Int):Array<NodeBase> {
		var cells = new Array<NodeBase>();
		for(i in 0 ... rows) {
			cells.push(getCell(column, i));
		}
		return cells;
	}
	
	public function getCell(x:Int, y:Int):NodeBase {
		if(x>=0 && x<columns && y>=0 && y<rows) {
			var index = (y * columns) + x;
			return _gridNodes[index];
		}
		return null;
	}

	private function _initCell(cell:NodeBase, x:Int, y:Int) {
		var w:Float = 100/columns;
		var h:Float = 100/rows;
		if(x>=0 && x<columns && y>=0 && y<rows) {
			// Keep track of containers
			var index = (y * columns) + x;
			if(_gridNodes[index] != null) {
				_gridNodes[index].parent = null; // Detach previous cell from parent
			}
			if(cell == null) {
				// By default create an AbsoluteContainer that fills the grid block
				cell = new AbsoluteContainer();
				cell.settings.width = Percent(w);
				cell.settings.height = Percent(h);
				cell.settings.alignX = PercentLT(w * x);
				cell.settings.alignY = PercentLT(h * y);

				if(hxfx.core.NodeBase.debug) {
					// Debug test, flip background colors of the grid
					var xMod = x % 2;
					var yMod = y % 2;
					var fMod = (xMod+yMod) % 2;
					if(fMod == 1) {
						cell.settings.bgColor = kha.Color.fromFloats(0,0,0,.3);
					} else {
						cell.settings.bgColor = kha.Color.fromFloats(0,0,0,.1);
					}
				}
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
