/**
 */
package sz.holos.vo {
	public class LoadVO {
		public var path : String;
		public var fail : Function ;
		public var result : Function ;
		public function LoadVO($path : String, $result : Function, $onFail : Function = null) {
			path = $path;
			result = $result;
			fail = $onFail;
		}
	}
}
