package sz.examples.load_progress {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	import sz.scratch.animation.Transitions;
	import sz.scratch.load.progress.ProgressAnimationAdapter;
	import sz.scratch.ui.CircleProgressAnimation;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 3/3/11
	 *
	 */
	public class app_ProgressAnimationSetup_singleSource extends MovieClip {
		private var _progressAnimation : CircleProgressAnimation;
		private var _progressDisplayAdapter : ProgressAnimationAdapter;
		private var _percent : Number = 0;
		private var _timer : Timer;
		private const INCREMENT : Number = 0.01;
		private const BYTES_TOTAL : Number = 100;

		public function app_ProgressAnimationSetup_singleSource() {
			_progressAnimation = new CircleProgressAnimation(40, 10, 0x00FF00, 1, 0xFF0000, .3);
			_progressAnimation.x = _progressAnimation.y = stage.stageWidth * .5;
			_progressAnimation.mouseEnabled = false;
			_progressAnimation.bkgThicknessOffset = 2;
			addChild(_progressAnimation);
			_progressAnimation.hideTransition = _animHideHandler;
			stage.addEventListener(MouseEvent.CLICK, _onClickAnim);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
			_progressDisplayAdapter = new ProgressAnimationAdapter();
			_progressDisplayAdapter.amtTotal = BYTES_TOTAL;
			_progressDisplayAdapter.animation = _progressAnimation;
			_timer = new Timer(50);
			_timer.addEventListener(TimerEvent.TIMER, _onTimer);
			_progressAnimation.indeterminate = true;
			setTimeout(_startLoading, 1000);
		}

		private function _startLoading() : void {
			_timer.start();
		}

		private function _onMouseMove(event : MouseEvent) : void {
			_progressAnimation.thickness = Math.max(3, Math.abs(this.mouseX - stage.stageWidth));
			_progressAnimation.radius = Math.min(50, Math.max(30, Math.abs(this.mouseY - stage.stageHeight)));
		}

		private function _onClickAnim(event : MouseEvent) : void {
			if(!_progressDisplayAdapter.indeterminate) {
				_progressDisplayAdapter.indeterminate = true;
				_timer.stop();
			}
			else {
				_progressDisplayAdapter.setMultiPercent(1);
			}
		}

		private function _animHideHandler() : void {
			Transitions.instance.fadeout([_progressAnimation]);
		}

		function _onTimer(e : TimerEvent) : void {
			_percent += INCREMENT;
			trace('_percent = ' + _progressDisplayAdapter.percent);
			_progressDisplayAdapter.setAmtLoaded(BYTES_TOTAL * _percent);
			if(_progressDisplayAdapter.percent >= 1)_timer.stop();
		}
	}
}
