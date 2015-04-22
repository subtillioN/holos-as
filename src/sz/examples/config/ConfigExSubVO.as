package sz.examples.config {
	import sz.holos.config.AutoParseVO;

	/**
	 *
	 */

	public class ConfigExSubVO extends AutoParseVO {
		public var id : String;
		public var type : String;
		public var title : String;
		public var check_txt : String;
		public var next_txt : String;
		public var previous_txt : String;
		public var replay_txt : String;
		public var content : String;
		/**
		 * an array of the possible answers or options for a question
		 */
		public var options : Array;
		public var contentPopID : String;

//		public static function parse($x : *, $assetPath : String) : FeatureItemVO
//		{
//			var vo : FeatureItemVO = new FeatureItemVO();
//			vo.parse($x);
//			vo.image = Model.dirPath+$assetPath+vo.image;
//			trace('________________________________________________________________________________\rindex = ' + vo.index);
//			return vo;
//		}
	}
}
