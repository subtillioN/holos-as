package sz.holos.application {
	import com.core.utils.FBtrace;

	import sz.holos.config.R;
	import sz.holos.type.ParseTypes;

	/**
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/4/11
	 *
	 */
	public class DisplayRoot extends ADisplayComponent {
		protected var _configPath : String = 'xml/config.xml',
				_deployRoot : String = "",
				_debugRoot : String = "",
				_testRoot : String = "../";

		public function DisplayRoot  ():void{
		}

		override protected function _bootReady() : void {
			_toString += " :: Application Class";
			setBootOptions(null,[Flags.CONFIG_READY],[__config]);
		}

		private function __config() : void {
			R.setRoots(_deployRoot, _testRoot, _debugRoot, ParseTypes.X, ParseTypes.IMG, ParseTypes.SWF);
			var p : String = R.getRoot(ParseTypes.X) + _configPath;
			R.config(_configPath, _onConfig, _onConfigFail);
			_config();
		}

		protected function _config() : void {}

		// async op handlers

		protected function _onConfig() : void {
			_bootSequence.setVal(Flags.CONFIG_READY, true);
		}

		protected function _onConfigFail(...rest) : void {
			FBtrace(this + 'ERROR :: CONFIG XML FAILED TO LOAD : ');
		}

	}
}