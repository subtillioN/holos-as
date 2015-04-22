package sz.holos.shape {
	import flash.geom.Point;

	/**
	 * Archimedean spiral generator
	 * e.g. drawShape(_g, makeArchiSpiral(0, 0, 100, 10, Num.PHI));
	 *
	 * @param $cX
	 * @param $cY
	 * @param numPoints
	 * @param angleWidth
	 * @param k
	 * @return
	 */
	public function makeArchiSpiral($cX : Number, $cY : Number, numPoints : Number, angleWidth : Number, k : Number) : Vector.<Point> {
		var v : Vector.<Point> = new Vector.<Point>();
		var p : Point;
		var angle : Number = 0;
		for(var t : Number = 0; t < numPoints; t++) {
			p = new Point(t * Math.sin(angle) * k, t * Math.cos(angle) * k);
			angle += Math.PI / 180.0 * angleWidth;
			v.push(p);
		}
		return v;
	}
}