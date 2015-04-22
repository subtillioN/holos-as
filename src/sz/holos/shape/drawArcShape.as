package sz.holos.shape {
	import flash.display.Sprite;

	public function drawArcShape($target : Sprite, $points : Array) : void {
		var origin : Vector.<Number> = $points.shift();
		$target.graphics.moveTo(origin[0], origin[1]);
		var p : Vector.<Number>;
		for each (p in $points) {
			$target.graphics.curveTo(p[0], p[1], p[2], p[3]);
		}
		$target.graphics.lineTo(origin[0], origin[1]);
	}
}