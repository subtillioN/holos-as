package sz.holos.logic {
	import com.core.utils.FlagSet;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/16/11
	 *
	 */
	public class ALinearState implements ILogicState{
		protected var _flags : FlagSet;
		public function ALinearState() {
			trace(this);
			_init();
		}

		private function _init() : void {

		}


		private function _trace(...rest) : void {
			trace(rest);
		}

		public function setVal($op : *, $val : Boolean) : void {
		}

		public function getState($op : *) : * {
			return false;
		}

		public function evaluate() : void {
		}

		public function set state($tempState : Boolean) : void {
		}

		public function resetState() : void {
		}
	}

}