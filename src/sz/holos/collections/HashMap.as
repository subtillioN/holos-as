package sz.holos.collections {
	import flash.utils.Dictionary;

	/**
	 * A simple indexed and iterative Dictionary
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/17/11
	 *
	 */
	public class HashMap {
		protected  var
				_keys : Array,
				_vals : Dictionary,
				_c:Cursor;

		public function HashMap($keys : Array = null, $vals : Array = null, $weakRef : Boolean = true, $loopOnIterate : Boolean = false) {
			_keys = [];
			_vals = new Dictionary();
			_c = new Cursor();
			if($keys && $vals)init($keys, $vals, $weakRef);
		}

		public function init($keys : Array, $vals : Array, $weakRef : Boolean = true) : void {
			addGroup($keys, $vals);
		}

		public function addGroup($keys : Array, $vals : Array, $at : int = -1) : void {
			for(var i : int = 0; i < $keys.length; i++) {
				add($keys[i], $vals[i], $at);
			}
		}

		public function getVal($k : *) : * {
			return _vals[$k];
		}

		public function setVal($k : *, $v : *) : Boolean {
			if(_vals[$k] != null) {
				_set($k, $v);
				return true;
			}
			return false;
		}

		public function getNext():*{return getValFromIndex(_c.next);}
		public function getPrevious():*{return getValFromIndex(_c.prev);}

		public function getValFromIndex($i : uint) : * {
			return _vals[_keys[$i]];
		}

		public function add($k : *, $v : *, $at : int = -1) : void {
			_set($k, $v);
			if($at == -1) {
				_keys.push($k);
			}
			else {
				_keys.splice($at, 0, $v);
			}
			_c.setBounds(0,_keys.length-1);
		}

		public function getIndex($k : *) : int {
			var i : int = -1;
			for each (var k : * in _keys) {
				i++;
				if($k == k)break;
			}
			return i;
		}

		protected function _set($k : *, $v : *) : void {
			_vals[$k] = $v;
		}

		public function get keys() : Array {
			return _keys.concat();
		}

		public function get vals() : Dictionary {
			return _vals;
		}

		public function get length() : Number {return _keys.length;}

		public function get valsArray() : Array {
			var v : Array = [];
			for(var i : int = 0; i < _keys.length; i++) {
				v.push(_vals[_keys[i]]);
			}
			return v;
		}
	}
}