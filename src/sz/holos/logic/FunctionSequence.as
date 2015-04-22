package sz.holos.logic {
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import sz.holos.collections.Cursor;
	import sz.holos.collections.IIterator;
	import sz.holos.type.utils.arrayToVector;

	/**
	 * A simple Function sequencer.
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/14/11
	 *
	 */
	public class FunctionSequence extends FunctionList implements IIterator {
		public var f : Function;
		protected var _c : Cursor;
		private var _timing : Vector.<Number> = new Vector.<Number>(),
				_timeOut : uint,
				_loop : Boolean,
				_callOnIterate : Boolean,
				_arg : *;

		/**
		 * @param $s : sequence Array which will be converted into the Function Vector
		 * @param $timing : Can be either a number or array.  If it is an array, the numbers will map the timing
		 *					 directly. Else the number will repeat to give a constant timer effect.
		 * @param $loop : determines if the function will loop.  Can use stop() to stop looping.
		 */
		public function FunctionSequence($s : Array, $timing : * = 0, $loop : Boolean = false, $callOnIterate : Boolean = true) {
			_c = new Cursor();
			_loop = $loop;
			_callOnIterate = $callOnIterate;
			super($s);
			timing = $timing;
		}

		override public function run($args : Array = null) : void {
			_c.setBounds(0, _list.length - 1);
			_arg = $args;
			_c.goNext();
		}

		private function _onCursor($i : int) : void {
			f = _list[$i];
			if(!_callOnIterate)   return;
			if(_arg[0] != null)f(_arg[0]);
			else f();
			if(!_loop && $i == _c.last)return;
			_timeOut = setTimeout(_c.goNext, _timing[$i]);
		}

		public function reset() : void {
			stop();
			_c.iterateUpdateHandler = null;
			_c.at(_c.last);
			_c.iterateUpdateHandler = _onCursor;
		}

		public function stop() : void {clearTimeout(_timeOut);}

		public function play() : void {
			_c.goNext();
		}

		public function set timing($delay : *) : void {
			if($delay is Number || $delay is int) {
				for(var i : int = 0; i < _list.length; i++) { _timing.push($delay)}
			} else if($delay is Array)arrayToVector($delay, _timing);
			while(_timing.length < _list.length) {_list.push(0)}
		}


		override public function set list($l : *) : void {
			super.list = $l;
			reset();
		}

		public function get c() : Cursor {
			return _c;
		}

		public function at($newPos : int = -1) : uint {
			return 0;
		}

		public function setBounds($first : uint, $last : uint) : void {
		}

		public function get hasPrev() : Boolean {
			return false;
		}

		public function get hasNext() : Boolean {
			return false;
		}

		public function get numSteps() : uint {
			return 0;
		}

		public function get i() : uint {
			return 0;
		}

		public function set iterateUpdateHandler($f : Function) : void {
		}

		public function goNext() : void {
		}

		public function goPrev() : void {
		}

		public function set loop(loop : Boolean) : void {
		}
	}
}