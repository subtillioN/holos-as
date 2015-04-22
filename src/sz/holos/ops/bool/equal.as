package sz.holos.ops.bool {
	public function equal($operands : Array) : Boolean {
		var r : Boolean = true;
		for(var i : int = 0; i < $operands.length - 1; i++) {
			if($operands[i] != $operands[i + 1]) {
				r = false;
				break;
				//TODO : test...
			}
		}
		return r;
	}
}