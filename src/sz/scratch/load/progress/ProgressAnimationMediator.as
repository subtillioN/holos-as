package sz.scratch.load.progress {
	import com.core.events.LoadEvent;

	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;

	/**
	 * Mediates interactions between ILoaderAnimation assets and loader objects.
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 3/3/11
	 *
	 */
	public class ProgressAnimationMediator extends EventDispatcher {
		private var _animation : IProgressAnimation;
		private var _percent : Number;
		private var _completeHandler : Function;
		private var _failHandler : Function;
		private var _progressCheckTimer : Timer;
		private var _loadObject : ILoaderProgressObject;

		public function ProgressAnimationMediator($progressCheckInterval : Number = 20) {
			_progressCheckTimer = new Timer($progressCheckInterval);
		}

		public function set percent($value : Number) : void {
			_percent = $value;
			if(!_animation)return;
			_animation.percent = $value;
			if($value >= 1){
				_progressCheckTimer.stop();
				_animation.hide();
				setTimeout(_loadingComplete,100);
			}
		}

		private function _loadingComplete() : void {

			if(_completeHandler != null)_completeHandler(_loadObject);
		}

		public function set loadObject($o : *) : void {
			if($o is ILoaderProgressObject) {
				_loadObject = $o;
			}
			else if($o is Array && LoaderProgressGroup.isValid($o)) {
				_loadObject = new LoaderProgressGroup($o);
			}
			else if(LoaderProgressObject.isValid($o)) {
					_loadObject = new LoaderProgressObject(_loadObject);
				}
				else if(LoaderProgressObjectByteConverter.isValid($o)) {
						_loadObject = new LoaderProgressObjectByteConverter($o);
					}
					else {
						throw new Error(this + " one or more load objects are invalid.");
					}
			_loadObject.addEventListener(LoadEvent.FAIL, _onFail);
			_startTimer();
		}


		private function _onFail(event : LoadEvent) : void {
			trace(this, " :: LOAD FAILURE");
			if(_failHandler != null)_failHandler(event);
		}


		private function _startTimer() : void {
			_progressCheckTimer.addEventListener(TimerEvent.TIMER, _onTimer);
			_progressCheckTimer.start();
		}

		private function _onTimer($e : TimerEvent) : void {
			percent = _loadObject.percent;
		}

		public function get loadObject() : ILoaderProgressObject {
			return _loadObject;
		}

		public function set indeterminate($value : Boolean) : void {
			if(_animation)_animation.indeterminate = $value;
		}

		public function get animation() : IProgressAnimation {
			return _animation;
		}

		public function set animation($do : IProgressAnimation) : void {
			_animation = $do;
		}

		public function get percent() : Number {return _percent;}

		public function get indeterminate() : Boolean {return _animation.indeterminate;}

		public function set completeHandler(value : Function) : void {
			_completeHandler = value;
		}

		override public function toString() : String {return "[" + getQualifiedClassName(this) + "] ";}

		public function set failHandler(value : Function) : void {
			_failHandler = value;
		}
	}
}