package sz.holos.ops {
	import sz.holos.math.Num;
	import sz.holos.ops.vector.vecNum;

	/**
	 * serves to handle common number errors due to the intersection of the two core conceptual axes in fundamental mathematics, and the infinities, NaNs, zeros they generate.
	 *
	 * @param $x
	 * @param $small - limit for immanent zero (infinity on the immanent/transcendent axis), defaults to Num.TINY
	 * @return
	 */
	public function safeNum($x : Number, $small : Number = NaN) : Number {
		trace('' + '$x = ' + $x);
		var r = $x;
		if(isNaN($x) || $x == 0)return isNaN($small) ? Num.TINY : $small;
		switch($x) {
			case Number.POSITIVE_INFINITY:
				r = Num.HUGE;
				break;
			case Number.NEGATIVE_INFINITY:
				r = Num.NEGATIVE_HUGE;
				break;
			default:
//				trace("safe(), value has fallen through... " + r);
		}
		report('sz.holos.ops.safeNum', r, vecNum(["$x",$x]));
		return r;
	}
}