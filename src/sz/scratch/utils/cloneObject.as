package sz.scratch.utils {
	/**
	 *
	 * takes an array of objects and quantizes, rounds, or 'snaps' the values of the $objects array to the nearest
	 * integer value for the properties passed as strings in the $props array argument
	 *
	 * @param $clones  Array - the objects to apply the quantizing to
	 * @param $props    Array - the properties on the objects to quantize
	 */
	public function cloneObject($donor : Object, $clones : Array, $props : Array) : void {
		for each (var o : Object in $clones) {
			for each (var prop : String in $props) {
				try {
					o[prop] = $donor[prop];
				} catch(error : Error) {
					trace("clone error: " + o + ' for ' + prop);
				} finally {
				}
			}
		}
	}
}
