/**
 * Example and testing of config process.
 *
 *
 * @author Joel Morrison
 * @version 1.0
 * @since 02.10.2011
 *
 */
package sz.examples.config {
	import com.core.mvc.locate;

	import flash.display.MovieClip;

	public class app_config extends MovieClip {
		public function app_config() {
			Controller(locate(Controller)).config("xml/config.xml", this);
		}
	}
}
