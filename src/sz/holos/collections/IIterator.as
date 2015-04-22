package sz.holos.collections {
	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/16/11
	 *
	 */
	public interface IIterator {
		function at($newPos : int = -1) : uint;

		function setBounds($first : uint, $last : uint) : void;

		function get hasPrev() : Boolean;

		function get hasNext() : Boolean;

		function get numSteps() : uint;

		function get i() : uint;

		function set iterateUpdateHandler($f : Function) : void;

		function goNext() : void;

		function goPrev() : void;

		function set loop(loop : Boolean) : void;
	}
}