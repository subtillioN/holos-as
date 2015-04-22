package sz.holos.logic {
	import flash.utils.Dictionary;

	import sz.holos.application.ILogicComponent;
	import sz.holos.factory.AControlledResource;

	import sz.holos.logic.LogicPattern;
	import sz.holos.logic.LogicSequence;

	/**
	 *  //// UNDER CONSTRUCTION ////
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/17/11
	 *
	 */
	public class LogicBus extends AControlledResource implements ILogicComponent{
		protected var _responsePatterns : Dictionary,
				_mainSequence : LogicPattern;
		private var _logicSequence : LogicSequence;
		public static const MAIN : String = "MAIN";

		public function LogicBus() {
			super();
		}

		override protected function _init() : void {
			_enforcementOptions = {type : LogicBus, passcode : 43751897, allowedInstances : 1, weakRef : false};
		}

		public function initSequence($sequence : Array, $callBack : Function = null, $type : String = "LINEAR", $defaultState : Boolean = false) : void {
			_logicSequence = new LogicSequence($sequence,$callBack,$type);
			_mainSequence = new LogicPattern(MAIN, $type, $sequence);
		}

		public function addResponsePattern($id : String, $type : String, $pattern : Array) : void {
			if(!_responsePatterns)_responsePatterns = new Dictionary();
			_responsePatterns[$id] = new LogicPattern($id, $type, $pattern);
		}

		public function removeResponsePattern($id : String, $type : String, $pattern : Array) : Boolean {
			if(!_responsePatterns || !_responsePatterns[$id]) return false;
			_responsePatterns[$id] = null;
			delete _responsePatterns[$id];
			return true;
		}

		public function run() : void {
		}

		public function stop() : void {
		}

		public function reset() : void {
		}

		public function evaluate() : void {
		}

		public function addStates(...rest) : void {
			trace('' + this + 'rest = ' + rest);
			trace('' + this + 'rest.length = ' + rest.length);
			_logicSequence.

		}

		public function get sequence() : LogicSequence {
			return _logicSequence;
		}
	}
}