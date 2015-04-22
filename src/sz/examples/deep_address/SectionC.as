/**
 * Created by IntelliJ IDEA.
 * User: jmorrison
 * Date: 2/1/11
 * Time: 10:07 AM
 * To change this template use File | Settings | File Templates.
 */
package sz.examples.deep_address {
	public class SectionC extends ASection {
		public function SectionC() {
//			_tweenPropAmt = 20;
//			_tweenProp = "x";
			_depth = 2;
		}

		override public function toString() : String {
			return "[SectionC]";
		}
	}
}
