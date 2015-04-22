package sz.scratch.ui {
	import com.core.events.NumberEvent;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * SliderControl DESCRIPTION
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since Nov 2, 2010
	 *
	 */
	public class SliderControl extends Sprite {
		public var hitZone : MovieClip ;
		public var transformShape : MovieClip ;
		public var size : MovieClip ;
		private var _percent : Number;
		public static const SLIDER_PERCENT : String = "sz.scratch.ui.SliderControl.percent";
		public function SliderControl() {
			hitZone.buttonMode = true;
			hitZone.addEventListener(MouseEvent.MOUSE_DOWN, _onDown, false, 0, true);
			hitZone.addEventListener(MouseEvent.MOUSE_UP, _onUp, false, 0, true);
			hitZone.addEventListener(MouseEvent.MOUSE_OUT, _onUp, false, 0, true);
		}

		private function _onUp(event : MouseEvent) : void {
			stage.removeEventListener(Event.ENTER_FRAME, _onFrame);
		}
		private function _onDown(event : MouseEvent) : void
		{
			stage.addEventListener(Event.ENTER_FRAME, _onFrame);
		}

		private function _onFrame(event : Event) : void {
			setPercent(this.mouseX/size.width,true);
		}

		public function setPercent($value : Number, $sendEvent : Boolean = false):void
		{
			var p : Number = Math.min(Math.max($value,0),1);
			if(_percent==p)return;
			_percent=p;
			transformShape.width = size.width * _percent;
			if($sendEvent) dispatchEvent(new NumberEvent(SLIDER_PERCENT,_percent));
		}
	}

}