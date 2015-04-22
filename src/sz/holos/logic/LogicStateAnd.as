package sz.holos.logic {
	import sz.holos.ops.bool.and;

	/**
	 * @author Joel Morrison
	 */
	public class LogicStateAnd extends LogicState implements ILogicState {

		/**
		 * @param pFlags An array of flag keys to wait for before calling back
		 * @param callBack The method to call when all flags have been set "true"
		 */
		public function LogicStateAnd() {
			_op = and;
		}
	}
}
