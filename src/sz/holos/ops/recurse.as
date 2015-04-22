package sz.holos.ops {
	public function recurse($x: Number, $y: Number, $op : Function, $limitCompare : Function, $limitVal : int, $limitMax : Number = 100) : Vector.<Number> {
		var r : Vector.<Number> = new Vector.<Number>();
		var i : int = 0;
		do{
			$x = $op($x,$y);
			r.push($x);
			i++;
		} while(i < $limitMax && $limitCompare([$x,$limitVal]));
		report("recurse r = " + r + "] -- ", 0);
		return r;
	}
}