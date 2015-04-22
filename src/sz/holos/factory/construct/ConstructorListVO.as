/**
 */
package sz.holos.factory.construct {
	import sz.holos.type.utils.arrayToVector;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 2/16/11
	 *
	 */
	public class ConstructorListVO extends ConstructorVO {
		public var list : Vector.<ConstructorVO>;

		public function ConstructorListVO($constructorVOs : Array) {
			super(null);
			list = arrayToVector($constructorVOs, new Vector.<ConstructorVO>());
		}
	}
}
