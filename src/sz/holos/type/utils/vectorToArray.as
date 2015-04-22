package sz.holos.type.utils {
	/**
	 *
	 * takes an array of objects and quantizes, rounds, or 'snaps' the values of the $objects array to the nearest
	 * integer value for the properties passed as strings in the $props array argument
	 *
	 * @param $clones  Array - the objects to apply the quantizing to
	 * @param $props    Array - the properties on the objects to quantize
	 */
	public function vectorToArray($v : *, $a : * = null) : Array {
		$a=[];
		for each (var j : * in $v) {
			$a.push(j);
		}
		return $a;
	}
}
