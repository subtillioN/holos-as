package sz.holos.js{
	import flash.external.ExternalInterface;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/20/11
	 *
	 */
	public class console {
		public function console() {
		}
		public static function log(...rest):void{
			if(ExternalInterface.available) {
				ExternalInterface.call("console.log", rest); // options: log, info, warn, error
			}
			trace(rest);
		}
	}
}