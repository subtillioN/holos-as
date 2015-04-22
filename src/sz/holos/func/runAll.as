package sz.holos.func {
	/**
	 *	run all your callback functions in a subscription vector, with one arg... dern rest/array snafu
	 */
	public function runAll($fv : Vector.<Function>, $args : Array = null) : void {
		var f : Function;
		if($fv) {
			for each (f in $fv) {
				f.apply(null,$args);
			}
		}
	}
}
