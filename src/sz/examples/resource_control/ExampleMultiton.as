package sz.examples.resource_control {
	import sz.holos.factory.AControlledResource;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/24/11
	 *
	 */
	public class ExampleMultiton extends AControlledResource {
		public var arg1 : String;
		public var arg2 : String;

		public function ExampleMultiton($resourceID : int, $arg1 : String, $arg2 : String) {
			arg1 = $arg1;
			arg2 = $arg2;
			super($resourceID);
		}

		public static function getInstance($key:*, $args : Array = null) : ExampleMultiton {
			return _getInstance($key, ExampleMultiton, 2, $args);
		}
	}
}