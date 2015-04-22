package sz.holos.type.utils {
	/**
	 *
	 * takes an array of objects and quantizes, rounds, or 'snaps' the values of the $objects array to the nearest
	 * integer value for the properties passed as strings in the $props array argument
	 *
	 * @param $clones  Array - the objects to apply the quantizing to
	 * @param $props	Array - the properties on the objects to quantize
	 */
	public function arrayToVector($a : Array, $v : *) : * {
		$v.length = 0;
		try {
			for each (var j : * in $a) {
				$v.push(j);
			}
		}
		catch(error : Error) {throw new Error(this + "ERROR : ALL OBJECTS IN ARRAY MUST BE FUNCTIONS :: MSG :: " + error.message); }
		return $v;
	}
}
