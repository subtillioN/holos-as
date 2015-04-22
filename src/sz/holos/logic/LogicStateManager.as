/**
 *
 * scheduled for deletion...replaced by bus and maybe tree ... eventually ...
 *
 *
 */
package sz.holos.logic {
	import flash.utils.Dictionary;

	import sz.holos.ops.bool.and;
	import sz.holos.ops.bool.or;
	import sz.holos.type.LogicTypes;

	public class LogicStateManager {

		private static var _logicStates : Dictionary;


		public static function addLogicStateObject($state_id : String, $operands : Array, $handler : Function, $type : String = null, $defaultState = false) : ILogicState {
			if(!$type)$type = LogicTypes.AND;
			if(!_logicStates)_logicStates = new Dictionary();
			var s : LogicState;
			var e : Function;
			switch($type) {
				case LogicTypes.AND:
					e = and;
					break;
				case LogicTypes.OR:
					e = or;
					break;
				default:
			}
			s = new LogicState();
			s.initStates($operands, $handler, $defaultState);

			_logicStates[$state_id] = s;
			return s;
		}


		public static function setState($state_id : String, $opId : String, $value : Boolean) : Boolean {
			var s : ILogicState = getStateObject($state_id);
			if(s) {
				s.setVal($opId, $value);
				return true;
			}
			return false;
		}

		public static function resetState($state_id : String) : void {
			var s : ILogicState = getStateObject($state_id);
			if(s) s.resetState();
			else trace('________________________________________________________________________________\r' +
							   'LogicStateManager :: No state, "' + $state_id + '", exists');
		}

		public static function getStateObject($state_id : String) : ILogicState {
			return _logicStates[$state_id] as ILogicState;
		}

		//--------------------------------------------------------------------------
		//
		//        SINGLETON CODE
		//

		//--------------------------------------------------------------------------
		private static var __instance : LogicStateManager;

		private static const SINGLETON_EXCEPTION : String = "SINGLETON EXCEPTION: LogicStateManager was instantiated outside Singleton context";

		/**
		 *  * Instantiates the LogicStateManager primary class
		 *  */
		public function LogicStateManager() {
			// Should never be called externally, LogicStateManager is a Singleton
			if(__instance)throw new Error(SINGLETON_EXCEPTION);
		}

		/**
		 *  * explicitly request the singleton instance of the LogicStateManager class
		 *  */
		public static function getInstance() : LogicStateManager {
			if(__instance)return __instance;
			__instance = new LogicStateManager();
			return __instance;
		}

		/**
		 *  * implicitly request the singleton instance of the LogicStateManager class
		 *  */
		public static function get instance() : LogicStateManager {
			if(__instance)return __instance;
			__instance = new LogicStateManager();
			return __instance;
		}
	}
}
