package sz.holos.application {
	import sz.holos.logic.ILogicSequence;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/17/11
	 *
	 */
	public interface ILogicComponent extends ILogicSequence {

		function run():void;
		function stop():void;
		function reset():void;
		function evaluate():void;

		function toString() : String;
	}
}