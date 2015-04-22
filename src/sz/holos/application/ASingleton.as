package sz.holos.application {
	import sz.holos.factory.Instantiator;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/24/11
	 *
	 */
	public class ASingleton {
		private var _instantiator:Instantiator;
		public function ASingleton($type:Class) {
			super(ASingleton, 1);
		}
	}
}