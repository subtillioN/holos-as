package sz.scratch.ui {
	import com.core.easing.Regular;
	import com.core.effects.Tween;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;

	import sz.scratch.load.progress.*;

	/**
	 *
	 * @author Joel Morrison
	 */
	public class ProgressMovieClip extends MovieClip implements IProgressAnimation {
		private var _tween : Tween;
		public var animFrames : MovieClip;
		public var base : MovieClip;
		private var _showTO : uint;
		private var _progressInt : int;
		private var _percent : Number;
		private var _shown : Boolean;
		private var _showAlways : Boolean;
		private var _animFrame : uint = 0;
		private var _framesTotal : Number = 1000;

		public function ProgressMovieClip() {
			mouseEnabled = false;
			mouseChildren = false;
			_shown = false;
			_showAlways = false;
			visible = false;
			animFrames.stop();
		}

		private function _showMe() : void {
			_shown = true;
			clearTimeout(_showTO);
			if(!visible) {
				visible = true;
				alpha = 0;
			}
			if(_tween)_tween.stop();
			_tween = new Tween(this, 'alpha', Regular.easeOut, NaN, 1, .3, true, 0);
		}

		private function _hideMe(event : Event = null) : void {
			_animFrame = 0;
			_shown = false;
			clearTimeout(_showTO);
			clearInterval(_progressInt);
			if(visible) {
				if(_tween)_tween.stop();
				_tween = new Tween(this, 'alpha', Regular.easeOut, NaN, 0, .3, true, 0);
				_tween.addEventListener(Event.COMPLETE, _onHidden);
			}
		}

		private function _onHidden($e : Event = null) : void {
			visible = false;
		}

		public function get percent() : Number {
			return _percent;
		}

		public function set percent(percent : Number) : void {
			_percent = percent;
			if(_percent < 1 && !_shown || _showAlways)_showMe();
			else if(_percent >= 1 && _shown && !_showAlways)_hideMe();
			var f : uint = Math.floor(_percent * _framesTotal) + 1;
			animFrames.gotoAndStop(f);
		}

		public function get framesTotal() : Number {
			return _framesTotal;
		}

		public function set framesTotal(value : Number) : void {
			_framesTotal = value;
		}

		public function get indeterminate() : Boolean {
			return false;
		}

		public function set indeterminate(value : Boolean) : void {
		}

		public function hide() : void {
		}
	}
}
