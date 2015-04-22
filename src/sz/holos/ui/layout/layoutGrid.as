package sz.holos.ui.layout {
	import flash.display.DisplayObject;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 2/10/11
	 *
	 */
	public function layoutGrid($items : Array, $isVertical : Boolean, $sideLength : int = 10, $x : int=0, $y : int=0, $padding : int = 0) {

		var ta : Number = 0;
		var tb : Number = 0;
		var i : int = 0;
		var dimA : String = $isVertical ? "y" : "x";
		var measureA : String = $isVertical ? "height" : "width";
		var dimB : String = $isVertical ? "x" : "y";
		var measureB : String = $isVertical ? "width" : "height";
		for each (var item : DisplayObject in $items) {
			item[dimA] = ta;
			item[dimB] = tb;
			if($sideLength == 1)ta += item[measureA];
			else if(i % $sideLength != 0) {
				ta += item[measureA] + $padding;
				tb = 0;
			}
			else {
				tb += item[measureB] + $padding;
			}
			i++;
		}
	}
}