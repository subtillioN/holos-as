package sz.holos.shape {
	public function rotateZ(x, y, center, dAngle) {
		//note: here dAngle is in arc unit PI format
		var dy = y - center.y;
		var dx = x - center.x;
		var orgAngle = Math.atan2(dy, dx);
		var hypo = Math.sqrt(dy * dy + dx * dx);
		var newAngle = orgAngle + dAngle;
		var xx = hypo * Math.cos(newAngle) + center.x;
		var yy = hypo * Math.sin(newAngle) + center.y;
		var pt = {x:xx, y:yy};
		return pt;
	}
}