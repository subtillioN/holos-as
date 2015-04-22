package sz.holos.shape {
	import flash.display.Graphics;

	public function draw($g : Graphics, $points : Array, $close : Boolean = false) : void {
		var origin : Vector.<Number> = $points.shift();
		$g.moveTo(origin[0], origin[1]);
		var p : Vector.<Number>;
		for each (p in $points) {
			$g.curveTo(p[0], p[1], p[2], p[3]);
		}
		if($close)$g.lineTo(origin[0], origin[1]);

	}
}