package sz.holos.shape {
	import flash.geom.Point;

	/**
	 * should be folded into general spiral, passing in log as the distance function ... or maybe just an array from recurse()?
	 *
	 * @param r
	 * @param a
	 * @param b
	 * @param dir
	 * @param cx
	 * @param cy
	 * @return
	 */

	public function logSpiralPoint(r : Number, a : Number, b : Number, dir : int, cx : Number = 0, cy : Number = 0) : Point {
		if(dir < 0) {dir = -1;} // just to make sure dir is -1 or 1
		else {dir = 1;}
		var pt : Point = new Point();
		pt.x = dir * a * Math.pow(Math.E, b * r) * Math.cos(r) + cx;
		pt.y = a * Math.pow(Math.E, b * r) * Math.sin(r) + cy;
		trace('' + this + 'pt.x = ' + pt.x);
		trace('' + this + 'pt.y = ' + pt.y);
		return pt;
	}
}