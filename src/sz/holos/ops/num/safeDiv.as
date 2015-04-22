package sz.holos.ops.num {
	import sz.holos.math.Num;
	import sz.holos.ops.safeNum;

	public function safeDiv($x: Number, $y: Number, $small: Number = NaN) : Number {
		return(safeNum($x,$small) / safeNum($y,Num.TINY));
	}
}