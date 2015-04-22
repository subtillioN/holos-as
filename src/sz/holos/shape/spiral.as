package sz.holos.shape {
	import flash.display.Graphics;

	/**
	 *
	 * @param $g
	 * @param centerX
	 * @param centerY
	 * @param orbits the rotations in terms of the distances
	 * @param rotate the value in radians to rotate on each draw, determining the resolution of the spiral
	 */
	public function spiral($g : Graphics, centerX: Number, centerY: Number, orbits:Vector.<Number>, rotate: Number ) {
		if(orbits.length!=orbit.length){
			trace("SPIRAL :: ERROR.  ORBIT AND RADII NEED TO MATCH LENGTH");
		}


		//
		//
		// Start at the center.
		$g.moveTo(centerX, centerY);
		//
		// How far to rotate around center for each side.
//		var aroundStep = coils / sides;// 0 to 1 based.
		//
		// Convert aroundStep to radians.
//		var aroundRadians = aroundStep * 2 * Math.PI;
		//
		// Convert rotation to radians.
//		rotation *= 2 * Math.PI;
		//
		// For every side, step around and away from center.
		for(var i = 0; i <= orbits.length-1; i++) {
			//
			// How far away from center
			var away = orbits[i];
			//
			// How far around the center.
			var around = i * aroundRadians + rotation;
//			var around = orbit[i];
			//
			// Convert 'around' and 'away' to X and Y.
			var x = centerX + Math.cos(around) * away;
			var y = centerY + Math.sin(around) * away;
			//
			// Now that you know it, do it.
			$g.lineTo(x, y);
		}
	}
}

//
//
// centerX-- X origin of the spiral.
// centerY-- Y origin of the spiral.
// radius--- Distance from origin to outer arm.
// sides---- Number of points or sides along the spiral's arm.
// coils---- Number of coils or full rotations. (Positive numbers spin clockwise, negative numbers spin counter-clockwise)
// rotation- Overall rotation of the spiral. ('0'=no rotation, '1'=360 degrees, '180/360'=180 degrees)
//
//function spiral(centerX, centerY, radius, sides, coils, rotation){
//    //
//    with(this){// Draw within the clip calling the function.
//        //
//        // Start at the center.
//
//    }
//}
//}