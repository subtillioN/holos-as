/**
 * simple config routine
 *
 */
package sz.examples.config {
	import com.core.mvc.AController;
	import com.core.utils.FBtrace;

	import flash.display.DisplayObjectContainer;
	import flash.events.Event;

	import sz.holos.config.R;
	import sz.holos.type.ParseTypes;
	import sz.holos.reflect.Introspect;

	public class Controller extends AController {

		public function config($xmlPath : String, $context : DisplayObjectContainer) : void {
			trace(this + 'config ');
			// parse the html context into the params VO
			R.setContext($context, PageParamsVO);
			Introspect.traceObject(R.params);
			// set the prefix of the config.xml path depending on testing vs. deployment modes
			R.setRoots("", "../", "", ParseTypes.X);
			// register parsers for the remaining XMLs
			R.registerParser("data", ConfigExVO.parse, _onQuizData, _onQuizLoadFail);
			// start the config process
			R.config($xmlPath, _onConfig, _onConfigLoadFail);
		}

		private function _onConfig() : void {
			_report(this + '_onConfig ');
			R.traceVals();
			Introspect.traceObject(R.params, true, "", true);
			// progress the lazy data when ready
			R.load(ParseTypes.X, "data");
			// you can also just call e.g. ...
//			R.getXML("data");

			var settingsVO : SettingsVO = R.getVO("settings");
			trace('settingsVO = ' + settingsVO);
		}

		private function _onConfigLoadFail($e : Event) : void {
			_report('' + this + '_onConfigLoadFail :: $e = ' + $e);
		}

		private function _onQuizData($data : ConfigExVO) : void {
			_report('' + this + '$data = ' + $data);
		}

		private function _onQuizLoadFail($e : Event) : void {
			_report('' + this + '_onQuizLoadFail :: $e = ' + $e);
		}

		private function _report(...rest) : void {
			FBtrace(rest);
		}
	}
}
