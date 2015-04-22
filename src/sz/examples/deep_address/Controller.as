/**
 * Created by IntelliJ IDEA.
 * User: jmorrison
 * Date: 2/1/11
 * Time: 1:00 PM
 * To change this template use File | Settings | File Templates.
 */
package sz.examples.deep_address {
	import com.core.mvc.AController;

	import sz.holos.site.DeepAddress;

	public class Controller extends AController{
		public var deepAddress : DeepAddress;
		public function Controller()
		{
			deepAddress = new DeepAddress();
		}
	}
}
