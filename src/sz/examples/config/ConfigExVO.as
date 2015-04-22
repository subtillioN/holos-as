package sz.examples.config {
	import sz.holos.config.R;
	import sz.holos.config.AutoParseVO;

	/**
	 * QuizVO is the value object for the common quiz data.
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

	public class ConfigExVO extends AutoParseVO {
		public var id : String;
		public var title : String;
		/**
		 * array of QuestionVOs
		 */
		public var questions : Array;

		public static function parse($x : *) : ConfigExVO {
			registerVOs(SettingsVO, ConfigExSubVO, ConfigExSubOptionVO);
			var vo : ConfigExVO = new ConfigExVO();
			vo.parse($x);
			R.setVal("data", vo);
			return vo;
		}
	}
}
