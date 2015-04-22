package sz.holos.type.utils {
	public function toArray($input : *) : Array {
		var a : Array=[];
		if($input.hasOwnProperty("length") && $input.length >= 0) {
			try {
				for each (var i : * in $input) { a.push(i)}
			} catch(error : Error) { trace("Error catch: " + error); }
			return a;
		}
		else return [$input];
	}
}