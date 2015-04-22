package sz.scratch.ui {
	public function disableMouse(...rest) {
		for each (var o : * in rest) {
			if(o.hasOwnProperty('mouseEnabled')) o.mouseEnabled = false;
			if(o.hasOwnProperty('mouseChildren')) o.mouseChildren = false;
		}
	}
}