package sz.holos.shape {
	import flash.display.Graphics;
	import flash.geom.Point;

	public function drawLines($g:Graphics,  vecPoints:Vector.<Point>) : void {
		var i : int;
		var n : int = vecPoints.length;
		var vecCmds : Vector.<int> = new Vector.<int>();
		var vecCoords : Vector.<Number> = new Vector.<Number>();

		for(i = 0; i < n; i++) {
			vecCmds[i] = 2;
			vecCoords[2 * i] = vecPoints[i].x;
			vecCoords[2 * i + 1] = vecPoints[i].y;
		}
		vecCmds[n] = 2;
		vecCoords[2 * n] = vecPoints[0].x;
		vecCoords[2 * n + 1] = vecPoints[0].y;
		vecCmds[0] = 1;
//		$g.clear();
//		$g.lineStyle(1, 0);
//		$g.beginFill(0xFF0000);
		$g.drawPath(vecCmds, vecCoords, vecWind[rbgWind.selectedData]);
		$g.endFill();
	}
}