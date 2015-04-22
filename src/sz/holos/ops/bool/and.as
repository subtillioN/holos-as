package sz.holos.ops.bool {
	public function and($operands : Array) : Boolean {
		var r : Boolean = true;
		for(var i : int = 0; i < $operands.length; i++) {
			if(!$operands[i]) {
				r = false;
			}
		}
		return r;
	}
}