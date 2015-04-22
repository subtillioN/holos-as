package sz.holos.shape {
	import flash.geom.Point;

	/**
	 * e.g. drawShape(myShape.graphics, spiral2(0,0,5.2,6,50,800));
	 *
	 * @param $cx
	 * @param $cy
	 * @param $zoom
	 * @param $r1
	 * @param $res
	 * @param $orbits
	 * @return
	 */
	public function makeSpiralLog2($cx : Number, $cy : Number, $zoom: Number, $r1: Number, $res: int, $orbits : Number) : Vector.<Point> {

		var
				angle : Number = 0,
				r2 : Number,
				fm : Number,
				angle2 : Number,
				dAngle : Number,
				n : Number = 1,
				v : Vector.<Point> = new Vector.<Point>();
		// Set initial properties

		fm = Math.pow($zoom, 1 / $res);
		dAngle = 2 * Math.PI / $res;

		for(var i : int = 0; i < $orbits; i++) {

			r2 = $r1 * fm;
			r2 = (n >= $orbits*0.5) ? $r1 / fm : $r1 * fm;
			angle2 = (n >= $orbits*0.5) ? angle + dAngle : angle - dAngle;

			var x1 : Number = $r1 * Math.cos(angle);
			var y1 : Number = $r1 * Math.sin(angle);
			v.push(new Point(x1+$cx, y1+$cy));

			// reset values
			angle = angle2;
			$r1 = r2;
			n++;
		}
		return v;

	}
}