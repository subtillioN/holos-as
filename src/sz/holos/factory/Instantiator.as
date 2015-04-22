package sz.holos.factory {
	import flash.utils.Dictionary;

	import sz.holos.factory.construct.construct;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/18/11
	 *
	 */
	public class Instantiator {
		private var
				_numInstances : int = 0,
				_numAllowed : int = -1,
				_type : Class,
				_instances : Dictionary;
		private static const
				ERROR_PREFIX : String = "\rInstantiator :: ERROR :: ",
				GEN_ERROR : String = " is a controlled resource and was instantiated incorrectly.";

		public function Instantiator($type : Class = null, $numAllowed : int = -1) {
			if($type)define($type, $numAllowed);
		}

		public function define($type : Class, $numAllowed : int = -1) : void {
			_type = $type;
			_numAllowed = $numAllowed;
			_instances = new Dictionary();
		}

		private function isValidInstantiation() : Boolean {
			var valid : Boolean;
			valid = _numAllowed < 0 || _numAllowed > _numInstances;
			return valid;
		}

		public function getInstance($key : *, $args : Array = null) : * {
			var i : * = _instances[$key];
			if(!i) {
				if(!isValidInstantiation()) {
					error();
					return null;
				}
				else {
					i = construct(_type, $args);
					_instances[$key] = i;
					_numInstances++;
				}
			}
			return i;
		}

		public function error($msg : String = null, $throw : Boolean = true) : void {
			if($throw)throw(new Error(ERROR_PREFIX + _type + GEN_ERROR + "\rMESSAGE :: " + $msg + "\r"));
			else {
				if($msg)trace("MESSAGE :: " + $msg + "\r");
				trace(ERROR_PREFIX + _type + GEN_ERROR);
			}
		}

		public static function error($type : String = null, $throw : Boolean = false) : void {
			if($throw)throw(new Error(ERROR_PREFIX + $type + GEN_ERROR + "\r"));
			else trace(ERROR_PREFIX + $type + GEN_ERROR);
		}
	}
}