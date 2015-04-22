/**
 */
package sz.holos.logic {

	import flash.events.Event;

	/**
	 * LogicStateEvent<br/>
	 * @author  Joel Morrison
	 * @since 11.13.2010
	 */
	public class LogicStateEvent extends Event {

		public static const TYPE_AND : String = "sz.holos.logic.LogicState.type_and";
		public static const TYPE_OR : String = "sz.holos.logic.LogicState.type_or";
		public static const CHANGED : String = "sz.holos.logic.LogicState.state_changed";

		private var _operandID : String;
		private var _value : Boolean;
		private var _logicType : String = TYPE_AND;

		/**
		 * Constructor<br/>
		 * Creates a new BooleanEvent instance.
		 * @param pType event type
		 * @param pBubbles boolean whether event should bubble
		 * @param pCancelable
		 * @return a new BooleanEvent instance
		 * usage:<br/>
		 * import com.core.events.BooleanEvent;
		 * var be:BooleanEvent = new BooleanEvent(EVENT.type);
		 */
		public function LogicStateEvent($type : String, $operandID : String, $value : Boolean, $logicType : String = null, $bubbles : Boolean = false, $cancelable : Boolean = false) : void {
			_operandID = $operandID;
			_value = $value;
			_logicType = $logicType;
			if(!$logicType)$logicType = TYPE_AND;
			super($type, $bubbles, $cancelable);
		}


		public function get operandID() : String {
			return _operandID;
		}

		public function set operandID(value : String) : void {
			_operandID = value;
		}

		public function get value() : Boolean {
			return _value;
		}

		public function set value(value : Boolean) : void {
			_value = value;
		}

		public function get logicType() : String {
			return _logicType;
		}

		public function set logicType(value : String) : void {
			_logicType = value;
		}
	}

}
