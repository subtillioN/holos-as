package sz.examples.config
{
	import sz.holos.config.AutoParseVO;

	/**
	 * VideoVO is the value object for the video data used in GALLERY section.
	 *
	 * <p>It extends ValueObject, so it gets parsed using the AutoParse
	 * functionality in the inherited 'parse()' method.  See the
	 * ValueObject and/or the AutoParse class for more info on customizing
	 * the built-in auto-parsing via overriding the inherited 'parse()' method.
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 12.2.2009
	 *
	 */

	public class ConfigExSubOptionVO extends AutoParseVO
	{
		public var id : String;
		public var title : String ;
		public var content : String ;
		public var response_header : String ;
		public var response : String ;

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
