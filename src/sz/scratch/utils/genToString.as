package sz.scratch.utils {
	import flash.utils.getQualifiedClassName;

	public function genToString($obj : *) : String {
		return "[" + getQualifiedClassName($obj) + "] ";
	}
}