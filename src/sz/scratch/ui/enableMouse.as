package sz.scratch.ui {
	public function enableMouse(...rest) {
		for each (var o : * in rest) {
			if(o.hasOwnProperty('mouseEnabled')) o.mouseEnabled = true;
			if(o.hasOwnProperty('mouseChildren')) o.mouseChildren = true;
		}
	}
}