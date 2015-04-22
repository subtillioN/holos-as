package sz.holos.shape {
	public function makeArcPoints($sx : Number, $sy : Number, $radius : Number, $arc : Number = 360, $direction : int = 1) : Array {
		var numOfSegs : Number = Math.ceil(Math.abs($arc) / 45);
		var segAngle : Number = $arc / numOfSegs;
		segAngle = (segAngle / 180) * Math.PI;
		var angle : Number = 0;
		var points : Array = [];
		var angleMid : Number;
		var bx : Number;
		var by : Number;
		var cx : Number;
		var cy : Number;
		var p : Vector.<Number>;
		var origin : Vector.<Number> = new Vector.<Number>();

		origin[0] = $sx + Math.cos(angle) * $radius;
		origin[1] = $sy + Math.sin(-angle) * $radius;

		for(var i : int = 0; i < numOfSegs; i++) {
			angle += segAngle;
			angleMid = angle - ($direction * (segAngle / 2));
			bx = $sx + Math.cos(angle) * $radius;
			by = $sy + Math.sin(angle) * $radius;
			cx = $sx + Math.cos(angleMid) * ($radius / Math.cos(segAngle / 2));
			cy = $sy + Math.sin(angleMid) * ($radius / Math.cos(segAngle / 2));
			p = new Vector.<Number>();
			p.push(cx, cy, bx, by);
			points.push(p);
		}
		if($direction == -1) {
			points.unshift(points[points.length - 1]);
			points.reverse();
		}
		if($arc == 360)points.unshift(origin);
		return points;
	}
}