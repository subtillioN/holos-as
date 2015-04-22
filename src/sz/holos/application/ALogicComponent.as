package sz.holos.application {
	import flash.utils.getQualifiedClassName;

	import sz.holos.logic.LogicSequence;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/17/11
	 *
	 */
	public class ALogicComponent implements ILogicComponent{
		protected var _toString:String = getQualifiedClassName(this);
		protected var _initParams:*;
		protected var _bus : LogicSequence;
		protected var _incl : Array = [];
		public function ALogicComponent() {
		}

		public function run():void{
			_bus.run(_initParams);
		}

		public function __init() : void {
		}

		public function _init() : void {
		}

		public function _onReady() : void {
		}

		public function stop() : void {
		}

		public function reset() : void {
		}

		public function evaluate() : void {
		}
	}

}