package sz.holos.shape {
	import flash.display.Graphics;
	import flash.geom.Point;

	public function drawShape($g:Graphics,$points:Vector.<Point>, $close : Boolean = true) {
		var i:int = 1;
		$g.moveTo($points[0].x,$points[0].y);
		for (i; i < $points.length-1 ; i++) {
			trace('' + this + 'i = ' + i);
		    $g.lineTo($points[i].x,$points[i].y);
			i++;
		}
		if($close)$g.lineTo($points[0].x,$points[0].y);
	}
}