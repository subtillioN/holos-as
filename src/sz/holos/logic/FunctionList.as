package sz.holos.logic {
	import sz.holos.type.utils.arrayToVector;
	import sz.holos.func.runAll;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/16/11
	 *
	 */
	public class FunctionList {
		protected var _list : Vector.<Function> = new Vector.<Function>();
		private var _disableRedundancy : Boolean = true;

		public function FunctionList($s : Array = null) {
			_list = new Vector.<Function>();
			if($s)list = $s;
		}

		public function run($args : Array = null) : void {
			runAll(_list, $args);
		}

		public function set list($l : *) : void {
			if($l is Array)arrayToVector($l, _list);
			else if($l is Vector.<Function>) _list = $l;
		}

		public function get list() : Vector.<Function> {
			return _list;
		}

		private function _addFunction($f : Function, $at : int = -1) : Boolean {
			if($f == null)return false;
			if(_disableRedundancy) {
				for each (var f : Function in _list) { if(f == $f)return false;}
			}
			if($at == -1)_list.push($f);
			else _list.splice($at, 0, $f);
			return true;
		}

		public function add($f : Array, $at : int = -1) : Boolean {
			var success : Boolean = true;
			for each (var f : Function in $f) {
				success = success && _addFunction(f, $at);
			}
			return success;
		}

		public function remove($f : Function) : Boolean {
			var i : int = 0;
			var success : Boolean;
			for each (var f : Function in _list) {
				if(f == $f) {
					success = true;
					break;
				}
				i++;
			}
			_list.splice(i, 0, $f);
			if(!_disableRedundancy && success)remove($f);
			return true;
		}

		public function removeAll() : void {
			_list.length = 0;
		}
	}
}