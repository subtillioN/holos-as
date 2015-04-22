package sz.scratch.load.progress {
	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 3/5/11
	 *
	 */
	public class LoaderProgressObjectByteConverter extends ALoaderProgressObject {
		public function LoaderProgressObjectByteConverter($o : *) {
			super($o);
		}

		override public function get percent() : Number {
			return _o.bytesLoaded / _o.bytesTotal;
		}

		public static function isValid($o : *) : Boolean {
			return($o.hasOwnProperty("bytesLoaded") && $o.hasOwnProperty("bytesTotal"));
		}
	}
}
