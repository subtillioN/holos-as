package sz.examples.config {
	import sz.holos.config.AutoParseVO;

	/**
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 12.2.2009
	 *
	 */

	public class SettingsVO extends AutoParseVO {
		public var id : String;
		public var title : String;
		public var address : Vector.<int> ;
	}
}
