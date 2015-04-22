package sz.scratch.load.progress {
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 3/5/11
	 *
	 */
	public class LoaderProgressObject extends ALoaderProgressObject {

		public function LoaderProgressObject($o : * = null) {
			super($o);
		}

		override public function get percent() : Number {
			try { if(_o && !isNaN(_o.percent))return _o.percent;} catch(e : Error) { }
			return .001;
		}

		public function set percent(value : Number) : void {
			_percent = value;
			if(_percent == 1)setTimeout(loadComplete,1);
		}

		override public function toString() : String {return "[" + getQualifiedClassName(this) + "] ";}

		public static function isValid($o : *) : Boolean {
			return($o.hasOwnProperty("percent"));
		}
	}
}
