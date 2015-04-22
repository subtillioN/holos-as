package sz.holos.ops {
	import sz.holos.ops.vector.vecNum;

	/**
	 *
	 *
	 * @param $ops
	 * @param $op
	 * @param $safe
	 * @return
	 */
	public function op($ops : Vector.<Number>, $op : Function, $safe : Boolean = false) : Number {
		trace(this + 'op ');
		var r : Number = $ops[0];
		for(var i : int = 0; i < $ops.length - 1; i++) {
			if($safe)r = safeNum(r);
			r = $op(vecNum([r, $ops[i + 1]]), $safe);
		}
		return r;
	}
}