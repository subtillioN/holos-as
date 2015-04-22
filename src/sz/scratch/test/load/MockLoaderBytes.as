package sz.scratch.test.load {
	/**
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 3/6/11
	 *
	 */
	public class MockLoaderBytes extends AMockLoader{
		public function MockLoaderBytes($bytesTotal : Number = NaN, $failDelay : Number = -1) {
			 super($bytesTotal,$failDelay);
		}
		public function get bytesTotal():Number{return _bytesTotal;}
		public function get bytesLoaded():Number{return _bytesLoaded;}
	}
}
