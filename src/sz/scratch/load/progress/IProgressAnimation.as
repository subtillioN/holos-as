/**
 * User: jmorrison
 * Date: 3/3/11
 * Time: 3:28 PM
 */
package sz.scratch.load.progress {
	public interface IProgressAnimation {
		// 0-1 values
		function get percent() : Number;
		function set percent($p : Number) : void;

		function get indeterminate() : Boolean;
		function set indeterminate(value : Boolean) : void;

		function hide() : void;
	}
}
