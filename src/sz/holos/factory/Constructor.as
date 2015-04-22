package sz.holos.factory {
	import flash.utils.Dictionary;

	/**
	 * Manages object construction via Instantiators.
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/17/11
	 *
	 */
	public class Constructor {
		private static var _instantiators : Dictionary;

		private static function _init() : void {
			if(!_instantiators)_instantiators = new Dictionary();
		}

		/**
		 * defines the properties for instantiation per type (Class), such as whether it is a singleton, multiton, or other.
		 *
		 * @param $type Class to be instantiated
		 * @param $numAllowed defaults to -1, which equals unlimited, otherwise it determines the number of different
		 * keyed instances allowable, creating either a singleton or multiton management setup
		 */
		public static function defineType($type : Class, $numAllowed : int = -1) : Instantiator {
			_init();
			if(!_instantiators[$type]) {
				_instantiators[$type] = new Instantiator($type, $numAllowed);
			} else trace("Constructor error : Instantiator of type " + $type + " already exists.");
			return _instantiators[$type];
		}

		public static function getInstance($key : *, $type : Class, $args : Array = null) : * {
			_init();
			return _getInstantiator($type).getInstance($key, $args);
		}

		private static function _getInstantiator($type : Class) : Instantiator {
			if(!_instantiators[$type]) {
				return defineType($type);
			} else return _instantiators[$type];
		}
	}
}