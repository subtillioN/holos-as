package sz.holos.shape {
	import flash.geom.Point;

	public function makeSpiralGen($radii:Vector.<Number>, a : Number, b : Number, dir : int, cx : Number = 0, cy : Number = 0) : Vector.<Point> {
		var pts : Vector.<Point> = new Vector.<Point>;
		for(var i : int = 0; i < $radii.length-1; i++) {
			pts.push(logSpiralPoint($radii[i], a, b, dir, cx, cy));
		}
		return pts;
	}
}