package sz.scratch.load.progress {
	import com.core.events.LoadEvent;

	import com.core.loading.LoadItem;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.utils.setTimeout;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 3/6/11
	 *
	 */
	public class ALoaderProgressObject extends EventDispatcher implements ILoaderProgressObject {
		protected var _o : *;

		protected var _percent : Number;
		private const ON_COMPLETE_DELAY : Number = 100;

		public function ALoaderProgressObject($o : * = null) {
			_o = $o;
			if(_o && _o is EventDispatcher) {
				EventDispatcher(_o).addEventListener(IOErrorEvent.IO_ERROR, _onError);
				EventDispatcher(_o).addEventListener(LoadEvent.FAIL, _onError);
			}
		}

		public function get percent() : Number {
			return 0;
		}

		public function getObject() : * {
			return _o;
		}

		private function _onError(event : Event) : void {
			dispatchEvent(new LoadEvent(LoadEvent.FAIL, true));
		}

		public function loadComplete() : void {
			setTimeout(_setComplete, ON_COMPLETE_DELAY);
		}

		private function _setComplete() : void {
			dispatchEvent(new Event(Event.COMPLETE, true, true));
		}

		public function getContent() : * {
			var content : *;
			if(getObject().hasOwnProperty('content')){
				return getObject().content;
			}
			return null;
		}
	}
}
