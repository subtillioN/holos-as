package sz.holos.logic {
	import sz.holos.collections.Cursor;
	import sz.holos.collections.IIterator;
	import sz.holos.ops.bool.and;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/16/11
	 *
	 */
	public class LogicSequence extends LogicState implements IIterator {
		protected var _functions : FunctionSequence,
				_c : Cursor;
		private var _sequenceUpdateHandler : FunctionList;

		public function LogicSequence() {
			super();
			_op = and;
		}

		private function _onCursorUpdate($i : int) : void {
			_trace('' + this + '_onCursorUpdate :: $i = ' + $i);
		}

		// LOGIC METHODS

		override public function setVal($op : *, $val : Boolean) : void {
			super.setVal($op, $val);
		}

		override public function getState($op : *) : * {
			return super.getState($op);
		}

		override public function set state($tempState : Boolean) : void {
			super.state = $tempState;
		}

		override public function resetState() : void {
			super.resetState();
		}

// FUNCTION SEQUENCE METHODS

		public function initFunctions($s : Array, $timing : * = 0, $loop : Boolean = false, $callOnIterate : Boolean = true) : void {
			_functions = new FunctionSequence($s, $timing, $loop, $callOnIterate);
			_c = _functions.c;
		}

		public function addFunctionToSequence($f : Array, $at : int = -1) : Boolean {
			return _functions.add($f, $at);
		}

		public function setTiming($timing : Array) : void {_functions.timing = $timing}

		public function run($params : Array = null) : void {
			_functions.run($params);
		}

		public function get functions() : FunctionSequence {
			return _functions;
		}

		public function set functions(value : FunctionSequence) : void {
			_functions = value;
		}

		// ITERATOR METHODS

		public function goPrev() : void {_c.goPrev();}

		public function goNext() : void {_c.goNext();}

		public function at($newPos : int = -1) : uint {
			return _c.at($newPos);
		}

		public function setBounds($first : uint, $last : uint) : void {_c.setBounds($first, $last);}

		public function get hasPrev() : Boolean {
			return _c.hasPrev;
		}

		public function get hasNext() : Boolean {
			return _c.hasNext;
		}

		public function get numSteps() : uint {
			return _c.numSteps;
		}

		public function get i() : uint {
			return _c.i;
		}

		public function set sequenceUpdateHandler($f : Function) : void {
			_sequenceUpdateHandler.add([$f]);
		}

		public function set loop(loop : Boolean) : void {
		}

		public function set iterateUpdateHandler($f : Function) : void { _c.iterateUpdateHandler = $f;}
	}
}