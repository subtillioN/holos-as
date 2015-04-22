package sz.holos.collections.utils {
	public function flatten2DArray($a : Array) : Array {

		var returnArray : Array = new Array();
		for(var y : uint = 0; y < $a.length; y++) {
			for(var x : uint = 0; x < $a[y].length; x++) {
				returnArray.push($a[y][x]);
			}
		}
		return returnArray;

	}
}