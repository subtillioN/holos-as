package sz.examples.load_progress {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BevelFilter;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
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
	public class app_ProgressAnimationSetup extends MovieClip {
		private var _progressAnimation : CircleProgressAnimation;
		private var _progressAnimationAdapter : ProgressAnimationAdapter;
		private var _percent : Number = 0;
		private var _timer : Timer;
		private const INCREMENT : Number = 0.01;
		private const BYTES_TOTAL_A : Number = 100;
		private const BYTES_TOTAL_B : Number = 100;
		private const BYTES_TOTAL_C : Number = 100;

		public function app_ProgressAnimationSetup() {
			_progressAnimation = new CircleProgressAnimation(40, 10, 0x555555, 1, 0x999999, .3);
			_progressAnimation.x = _progressAnimation.y = stage.stageWidth * .5;
			_progressAnimation.bkg.filters=[new BlurFilter(8,8)];
			_progressAnimation.bkg.x=_progressAnimation.bkg.y=8;
			_progressAnimation.progressAnimation.filters=[new GlowFilter(0xFFFFFF1,1,12,12,2,1,true,false)];
			_progressAnimation.mouseEnabled = false;
			addChild(_progressAnimation);
			_progressAnimation.hideTransition = _animHideHandler;
			stage.addEventListener(MouseEvent.CLICK, _onClickAnim);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
			_progressAnimationAdapter = new ProgressAnimationAdapter();
			_progressAnimationAdapter.multiAmtTotal = [BYTES_TOTAL_A,BYTES_TOTAL_B,BYTES_TOTAL_C];
			_progressAnimationAdapter.animation = _progressAnimation;
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
			if(!_progressAnimationAdapter.indeterminate) {
				_progressAnimationAdapter.indeterminate = true;
				_timer.stop();
			}
			else {
				_progressAnimationAdapter.setMultiPercent(1);
			}
		}

		private function _animHideHandler() : void {
			Transitions.instance.fadeout([_progressAnimation]);
		}

		function _onTimer(e : TimerEvent) : void {
			_percent += INCREMENT;
			trace('_percent = ' + _progressAnimationAdapter.percent);
			_progressAnimationAdapter.setAmtLoaded(BYTES_TOTAL_A * _percent, 0);
			_progressAnimationAdapter.setAmtLoaded(BYTES_TOTAL_B * _percent, 1);
			_progressAnimationAdapter.setAmtLoaded(BYTES_TOTAL_C * _percent, 2);
			if(_progressAnimationAdapter.percent >= 1)_timer.stop();
		}
	}
}
