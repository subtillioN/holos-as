package sz.holos.logic {
	import sz.holos.ops.bool.or;

//	TODO: TEST THIS CLASS...

	/**
	 * AndState contains multiple flags, triggers a _trueCallback when all flags are set to true, and triggers _falseCallBack when one is set to false
	 * @author Joel Morrison
	 */
	public class LogicStateOr extends LogicState implements ILogicState {
		/**
		 * Constructor
		 * @param pFlags An array of flag keys to wait for before calling back
		 * @param callBack The method to call when all flags have been set "true"
		 */
		public function LogicStateOr() {
			_op = or;
		}
	}
}
