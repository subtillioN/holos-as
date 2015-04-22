package sz.holos.collections.utils {
	public function formatArray(a : Array) : String {
		var result : String = "";
		for(var i : int = 0; i < a.length; i++) {
			if(a[i] is Array)
				result += formatArray(a[i]);
			else if(a[i] == null)
				; // Do nothing
			else
				result += String(a[i]);
			result += ",";
		}
		// Trim off last comma:
		if(result.charAt(result.length - 1) == ',')
			result = result.substring(0, result.length - 1);
		return "[" + result + "]";
	}
}