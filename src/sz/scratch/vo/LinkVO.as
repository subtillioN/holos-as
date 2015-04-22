/**
 */
package sz.scratch.vo {
	import sz.holos.config.AutoParseVO;

	public class LinkVO extends AutoParseVO{
		public var id : String = "LINK";
		public var title : String = "Link";
		public var URL : String;
		public var target : String = "_blank";
		public var jsCall : Array;
		public var x : Number;
		public var y : Number;
	}
}
