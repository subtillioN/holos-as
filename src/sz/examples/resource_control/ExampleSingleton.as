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
	public class ExampleSingleton extends AControlledResource {
		public function ExampleSingleton($resourceID : int = -1) {
			super($resourceID);
		}

		public static function get instance() : ExampleSingleton { return _getSingleton(ExampleSingleton);}
	}
}