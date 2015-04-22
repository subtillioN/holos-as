package sz.holos.factory {
	/**
	 *
	 * Base class for instance resource control system, i.e. singletons and multitons.
	 *
	 *
	 *
	 * Examples:
	 *
	 *
	 * public class ExampleSingleton extends AControlledResource {
	 *	   public function ExampleSingleton($resourceID : int = -1) {
	 *			 super($resourceID);
	 *	   }
	 *
	 *	   public static function get instance() : ExampleSingleton { return _getSingleton(ExampleSingleton);}
	 * }
	 *
	 * var s1 : ExampleSingleton = ExampleSingleton.instance;
	 *
	 *
	 *
	 * public class ExampleMultiton extends AControlledResource {
	 *	   public var arg1 : String;
	 *	   public var arg2 : String;
	 *
	 *	   public function ExampleMultiton($resourceID : int, $arg1 : String, $arg2 : String) {
	 *			 arg1 = $arg1;
	 *			 arg2 = $arg2;
	 *			 super($resourceID);
	 *	   }
	 *
	 *	   public static function getInstance($key, $args : Array = null) : ExampleMultiton {
	 *			 return _getInstance($key, ExampleMultiton, 2, $args);
	 *	   }
	 *}
	 *
	 * var s1 : ExampleMultiton = ExampleMultiton.getInstance("a",["a1","a2"]);
	 *
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/17/11
	 *
	 */
	public class AControlledResource {

		protected static var _instantiator : Instantiator;
		protected static var _resourceID : int = Math.random() * 100000000;
		protected static var _args : Array;

		public function AControlledResource($resourceID : int = -1) {
			if(_resourceID != $resourceID)Instantiator.error(this + '', true);
		}

		protected static function _getSingleton($type : Class, $args : Array = null) : * {
			return _getInstance(_resourceID, $type, 1, $args);
		}

		protected static function _getInstance($key : *, $type : Class, $numAllowed : int = 1, $args : Array = null) : * {
			if(!_instantiator) {
				_instantiator = new Instantiator($type, $numAllowed);
			}
			_setArgs($args);
			return _instantiator.getInstance($key, _args);
		}

		private static function _setArgs($args : Array = null) : void {
			_args = [_resourceID];
			if($args)_args = _args.concat($args);
		}
	}
}
