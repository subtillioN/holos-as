package sz.holos.ops {
	public function report($m : String, $r : Number, $a: Vector.<Number> = null) : void {

		var s: String = '';
			for each (var n:Number in $a){ s+=" :"}
			trace('Num :: ' + $m + '--> r = ' + $r + s);
	}
}