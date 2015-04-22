package sz.scratch.utils {
	/**
	 *  takes a $source object and copies the dynamic properties onto the $target object.
	 */
	public function cloneObjectProperties($source : Object, $target : *) : void {
		var targets : Array = [];
		if($target is Object)targets = [$target];
		else if($target is Array)targets = $target;
		for each (var o : Object in targets) {
			for(var prop in $source) {
				try {
					o[prop] = $source[prop];
				} catch(error : Error) {
					trace("cloneProperties error: " + o + ' for ' + prop);
				} finally {
				}
			}
		}
	}
}