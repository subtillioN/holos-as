package sz.holos.application {
	import flash.display.MovieClip;

	import sz.holos.config.R;
	import sz.holos.logic.LogicSequence;
	import sz.holos.reflect.Introspect;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/16/11
	 *
	 */
	public class ADisplayComponent extends MovieClip {
		protected var
				_bootSequence : LogicSequence,
				_includes : Array = [],
				_runArgs : Array = [],
				_toString : String = "";

		public function ADisplayComponent() {
			_toString = Introspect.getClassName(this, false);
			_bootSequence = new LogicSequence();
			_bootSequence.initStates([], _onReady);
			_bootSequence.initFunctions([__init]);
			_bootReady();
		}

		protected function _bootReady() : void {
			// a good place to setBootOptions and call boot.
		}

		public function setBootOptions($args : Array = null, $asyncFlags : Array = null, $bootFunctions : Array = null) : void {
			if($args) _runArgs.push($args);
			if($asyncFlags) _bootSequence.addStates($asyncFlags);
			if($bootFunctions) _bootSequence.addFunctionToSequence($bootFunctions);
		}

		public function boot() : void {
			_bootSequence.run(_runArgs);
		}

		private function __init() : void {
			_init();
			R.register(_includes);
		}

		protected function _init() : void {}

		protected function _onReady($state : Boolean) : void {
		}

		override public function toString() : String {
			return "[" + _toString + "] ";
		}
	}

}