package sz.scratch.test.load {
	import com.core.events.LoadEvent;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;

	import sz.scratch.utils.Random;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 3/5/11
	 *
	 */
	public class AMockLoader extends EventDispatcher {
		public static var SPEED : Number = 0.25;
		public static var TIMER_DELAY : Number = 10;
		protected var _percent : Number = 0;
		protected var _bytesTotal : Number;
		protected var _bytesLoaded : Number = 0;
		private var _errorDelay : Number = -1;
		private var _timer : Timer;

		public function AMockLoader($bytesTotal : Number = NaN, $failDelay : Number = -1) {
			if(isNaN($bytesTotal))$bytesTotal = Random.range(333, 1857);
			_bytesTotal = $bytesTotal;
			trace('_totalBytes = ' + _bytesTotal);
			_errorDelay = $failDelay;

			_timer = new Timer(TIMER_DELAY);
			_timer.addEventListener(TimerEvent.TIMER, _updateLoadProgress);
		}

		protected function _updateLoadProgress($e : TimerEvent) : void {
			_bytesLoaded += SPEED;
			_percent = _bytesLoaded / _bytesTotal;
			if(_percent >= 1)_loadComplete();
		}

		private function _loadComplete() : void {
			trace(this + '_loadComplete ');
			_timer.stop();
			dispatchEvent(new Event(Event.COMPLETE));
		}

		public function load() : void {
			_timer.start();
			if(_errorDelay > 0)setTimeout(produceError, _errorDelay);
		}

		public function produceError() : void {
			dispatchEvent(new LoadEvent(LoadEvent.FAIL));
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			stopLoad();
		}

		public function stopLoad() : void {
			_timer.stop();
		}

		override public function toString() : String {return "[" + getQualifiedClassName(this) + "] ";}
	}
}
