/**
 * Created by IntelliJ IDEA.
 * User: jmorrison
 * Date: 2/1/11
 * Time: 10:06 AM
 * To change this template use File | Settings | File Templates.
 */
package sz.examples.deep_address {
	public class SectionB extends ASection {
		public function SectionB() {
//			_tweenPropAmt = 40;
//			_tweenDelay = .1;
//			_tweenProp = "y";
			_depth = 1;
		}

		override public function toString() : String {
			return "[SectionB]";
		}
	}
}
