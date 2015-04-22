package sz.scratch.ui {
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 5/15/11
	 *
	 */
	public class ModalBackground extends Sprite {
		private var _onClick : Function;
		private var _onOver : Function;
		private var _onOut : Function;
		private var _onShow : Function;
		private var _onHide : Function;


		private static var __instance : ModalBackground;
		private static const SINGLETON_EXCEPTION : String = "SINGLETON EXCEPTION: ModalBackground was instantiated outside Singleton context";
		private var _p : DisplayObjectContainer;
		private var _color : uint;
		private var _alpha : Number;
		private var _isModal : Boolean;


		public function init($parent : DisplayObjectContainer, $color : uint = 0x000000, $alpha : Number = 0.5, $isModal = true, $isInteractive = true) : ModalBackground {
			_p = $parent;
			_color = $color;
			_alpha = $alpha;
			isModal = $isModal;
			if(!$isInteractive){
				mouseChildren = mouseEnabled = false;
			}
			if(_checkStage())_draw();
			return instance;
		}

		private function _draw() : void {
			if(!_checkStage())return;
			with(this.graphics) {
				clear();
				beginFill(_color, _alpha);
				drawRect(0, 0, _p.stage.stageWidth, _p.stage.stageHeight);
				endFill();
			}
			cacheAsBitmap = true;
		}

		private function _checkStage() : Boolean {
			if(!_p.stage) {
				_p.addEventListener(Event.ADDED_TO_STAGE, _onStage);
				return false;
			}
			return true;
		}

		private function _onStage(event : Event) : void {
			_p.removeEventListener(Event.ADDED_TO_STAGE, _onStage);
			_draw();
		}

		public function show() : void {
			if(_onShow != null)_onShow();
			visible = true;
		}

		public function hide() : void {
			if(_onHide != null)_onHide();
			else visible = false;
		}

		public function set p(value : DisplayObjectContainer) : void {
			_p = value;
		}

		public function set color(value : uint) : void {
			_color = value;
			_draw()
		}

		public function set onShow(value : Function) : void {
			_onShow = value;
		}

		public function set onHide(value : Function) : void {
			_onHide = value;
		}

		public function set onClick(value : Function) : void {
			_onClick = value;
			if(_onClick!=null)addEventListener(MouseEvent.CLICK, _clickHandler, false, 0, true);
			else removeEventListener(MouseEvent.CLICK, _clickHandler);
		}

		private function _clickHandler(event : MouseEvent) : void {
			_onClick();
		}

		public function set onOver(value : Function) : void {
			_onOver = value;
			if(_onOver!=null)addEventListener(MouseEvent.MOUSE_OVER, _overHandler);
			else removeEventListener(MouseEvent.MOUSE_OVER, _overHandler);
		}

		private function _overHandler(event : MouseEvent) : void {
			_onOver();
		}

		public function set onOut(value : Function) : void {
			_onOut = value;
			if(_onOut!=null)addEventListener(MouseEvent.MOUSE_OVER, _outHandler);
			else removeEventListener(MouseEvent.MOUSE_OVER, _outHandler);
		}

		private function _outHandler(event : MouseEvent) : void {
			_onOut();
		}

		public function get isModal() : Boolean {
			return _isModal;
		}

		public function set isModal(value : Boolean) : void {
			_isModal = value;
		}


		/**
		 *Instantiates the ModalBackground primary class
		 */

		public function ModalBackground() {
// Should never be called externally, ModalBackground is a Singleton
			if(__instance)throw new Error(SINGLETON_EXCEPTION);
		}

		/**
		 * explicitly request the singleton instance of the ModalBackground class
		 */

		public static function getInstance() : ModalBackground {
			if(__instance)return __instance;
			__instance = new ModalBackground();
			return __instance;
		}

		/**
		 * implicitly request the singleton instance of the ModalBackground class
		 */

		public static function get instance() : ModalBackground {
			if(__instance)return __instance;
			__instance = new ModalBackground();
			return __instance;
		}


	}
}