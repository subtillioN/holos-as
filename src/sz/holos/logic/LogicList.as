package sz.holos.logic {
	import sz.holos.collections.Cursor;
	import sz.holos.collections.IIterator;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/16/11
	 *
	 */
	public class LogicList extends LogicState implements IIterator{
		protected var _:;
		public function LogicList($op : Array, $callBack : Function = null, $defaultState : Boolean = false) {
			super($op, $callBack, $defaultState);
		}

		public function at($newPos : int = -1) : uint {
			return 0;
		}

		public function setBounds($first : uint, $last : uint) : void {
		}

		public function get hasPrev() : Boolean {
			return false;
		}

		public function get hasNext() : Boolean {
			return false;
		}

		public function get numSteps() : uint {
			return 0;
		}

		public function get i() : uint {
			return 0;
		}

		public function set iterateUpdateHandler($f : Function) : void {
		}

		public function goNext() : void {
		}

		public function goPrev() : void {
		}

		public function set loop(loop : Boolean) : void {
		}
	}
}