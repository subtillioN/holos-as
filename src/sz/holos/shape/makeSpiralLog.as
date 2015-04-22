package sz.holos.shape {
	import flash.geom.Point;

	public function makeSpiralLog(numPoints : int, a : Number, b : Number, dir : int, cx : Number = 0, cy : Number = 0) : Vector.<Point> {
		var pts : Vector.<Point> = new Vector.<Point>;
		for(var i : int = 0; i < numPoints; i++) {
			pts.push(logSpiralPoint(i, a, b, dir, cx, cy));
		}
		return pts;
	}
}