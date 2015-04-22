package sz.holos.logic {
	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/14/11
	 *
	 */
	public interface ILogicState {
		/**
		 * setFlag($op,pVal)
		 * Sets a operand either on or off. Setting a operand to "off" is also a method to create a new operand to wait for.
		 * @param $op Any key, instance or String value.
		 * @param $val Boolean, true if the operand is set, false if it must be waited for.
		 */
		function setVal($op : *, $val : Boolean) : void;

		/**
		 * getState($op)
		 * returns the status of the specified operand
		 * @param $op The operand to check
		 * @return Boolean false if waiting on this operand, true of not. Undefined operands will return true.
		 */
		function getState($op : *) : *;

		/**
		 * Internal method to check if all operands are now deleted (ready state).
		 */
		function evaluate() : void;

		function set state($tempState : Boolean) : void;

		function resetState() : void;
	}
}