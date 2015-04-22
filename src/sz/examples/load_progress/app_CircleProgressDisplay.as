package sz.examples.load_progress {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	import sz.scratch.animation.Transitions;
	import sz.scratch.ui.CircleProgressDisplay;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 3/3/11
	 *
	 */
	public class app_CircleProgressDisplay extends MovieClip {
		private var _circleProgressDisplay : CircleProgressDisplay;
		private var _percent : Number = 0;
		private var _timer : Timer;
		private const INCREMENT : Number = 0.01;

		public function app_CircleProgressDisplay() {
			_circleProgressDisplay = new CircleProgressDisplay(40, 3, 0x00FF00, 1, 0x99FF99, .3);
			_circleProgressDisplay.x = _circleProgressDisplay.y = stage.stageWidth * .5;
			_circleProgressDisplay.mouseEnabled = false;
			_circleProgressDisplay.anim.bkgThicknessOffset = 5;
			_circleProgressDisplay.anim.progressAnimation.filters = [new BlurFilter(2,2), new GlowFilter(0x00FF00, 1, 15, 15, 1, 1, false, false)];
			_circleProgressDisplay.anim.bkg.filters = [new BlurFilter()];
			addChild(_circleProgressDisplay);
			_circleProgressDisplay.anim.hideTransition = _animHideHandler;
			stage.addEventListener(MouseEvent.CLICK, _onClickAnim);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
			_timer = new Timer(50);
			_timer.addEventListener(TimerEvent.TIMER, _onTimer);
			_circleProgressDisplay.logic.indeterminate = true;
			setTimeout(_startLoading, 1000);
		}

		private function _startLoading() : void {
			_timer.start();
		}

		private function _onMouseMove(event : MouseEvent) : void {
			_circleProgressDisplay.anim.thickness = Math.max(3, Math.abs(this.mouseX - stage.stageWidth));
			_circleProgressDisplay.anim.radius = Math.min(50, Math.max(30, Math.abs(this.mouseY - stage.stageHeight)));
		}

		private function _onClickAnim(event : MouseEvent) : void {
			if(!_circleProgressDisplay.logic.indeterminate) {
				_circleProgressDisplay.logic.indeterminate = true;
				_timer.stop();
			}
			else {
				_circleProgressDisplay.logic.percent = 1;
			}
		}

		private function _animHideHandler() : void {
			Transitions.instance.fadeout([_circleProgressDisplay]);
		}

		function _onTimer(e : TimerEvent) : void {
			_percent += INCREMENT;
			trace('_percent = ' + _circleProgressDisplay.logic.percent);
			_circleProgressDisplay.logic.percent = _percent;
			if(_circleProgressDisplay.logic.percent >= 1)_timer.stop();
		}
	}
}
