package sz.holos.collections {
	import sz.holos.logic.FunctionList;
	import sz.holos.collections.IIterator;

	/**
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 1/25/11
	 *
	 */
	public class Cursor implements IIterator {
		private var _first : uint = 0;
		private var _last : uint = 9;
		private var _loop : Boolean = true;
		private var _i : int = 0;
		private var _numSteps : uint;
		private var _updateHandler : FunctionList;

		public function Cursor($last : uint = 9, $first : uint = 0, $loop : Boolean = true) {
			setBounds($first, $last);
			_loop = $loop;
		}

		public function get prev() : uint {
			_i--;
			_clipMin();
			_dispatchUpdate();
			return _i;
		}

		public function get next() : uint {
			_i++;
			_clipMax();
			_dispatchUpdate();
			return _i;
		}

		public function at($newPos : int = -1) : uint {
			if($newPos != -1)_i = $newPos;
			_clipMax();
			_clipMin();
			_dispatchUpdate();
			return _i;
		}

		public function setBounds($first : uint, $last : uint) : void {
			if($last < $first) {
				trace(this + " ERROR :: BOUNDS, LAST (" + $last + ") SHOULD BE GREATER THAN FIRST (" + $first + ").");
				return;
			}
			_first = $first;
			_last = $last;
			_numSteps = _last - _first;
		}

		public function get first() : uint {
			return _first;
		}

		public function get last() : uint {
			return _last;
		}

		public function get hasPrev() : Boolean {
			return (_i - 1 >= _first);
		}

		public function get hasNext() : Boolean {
			return (_i + 1 <= _last);
		}

		public function get numSteps() : uint {
			return _numSteps;
		}

		private function _clipMin() : void {
			if(_i < _first) {
				if(_loop)_i = _last;
				else _i = _first;
			}
		}

		private function _clipMax() : void {
			if(_i > _last) {
				if(_loop)_i = _first;
				else _i = _last;
			}
		}

		public function get i() : uint {return _i;}

		private function _dispatchUpdate() : void {
			if(_updateHandler != null)_updateHandler.run([_i]);
		}

		public function set iterateUpdateHandler($f : Function) : void {
			if(!_updateHandler)_updateHandler = new FunctionList();
			if($f == null)_updateHandler.removeAll();
			_updateHandler.add([$f]);
		}

		public function goNext() : void {
			_i = next;
		}

		public function goPrev() : void {
			_i = prev;
		}

		public function set loop(loop : Boolean) : void {_loop = loop;}
	}
}