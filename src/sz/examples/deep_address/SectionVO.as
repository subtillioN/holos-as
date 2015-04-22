/**
 * Created by IntelliJ IDEA.
 * User: jmorrison
 * Date: 2/1/11
 * Time: 10:47 AM
 * To change this template use File | Settings | File Templates.
 */
package sz.examples.deep_address {
	import sz.holos.config.AutoParseVO;

	public class SectionVO extends AutoParseVO {
		public var id : String;
		public var path : String;
		public var title : String;

		public static function parse($x : *) : SectionVO {
			var vo : SectionVO = new SectionVO();
			if($x)vo.parse($x);
			return vo;
		}
	}
}
