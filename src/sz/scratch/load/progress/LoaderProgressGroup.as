package sz.scratch.load.progress {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;

	import sz.holos.type.utils.vectorToArray;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 3/5/11
	 *
	 */
	public class LoaderProgressGroup extends LoaderProgressObject implements ILoaderProgressObject {
		private var _list : Vector.<ILoaderProgressObject>;
		private var _numComplete : int;

		public function LoaderProgressGroup($array : Array) {
			if(!isValid($array)) {
				throw new Error(this + " one or more load objects in array are invalid.");
			}
			_list = new Vector.<ILoaderProgressObject>();
			var o : EventDispatcher;
			for each (o in $array) {
				if(LoaderProgressObject.isValid(o)) {
					_list.push(new LoaderProgressObject(o));
				}
				else if(LoaderProgressObjectByteConverter.isValid(o)) {
					_list.push(new LoaderProgressObjectByteConverter(o));
				}
				o.addEventListener(Event.COMPLETE, _onComplete);
			}
		}

		private function _onComplete(event : Event) : void {
			event.stopImmediatePropagation();
			_numComplete++;
			if(_numComplete<_list.length)return;
			dispatchEvent(new Event(Event.COMPLETE));
		}

		override public function get percent() : Number {
			var p : Number = 0;
			for each (var o : ILoaderProgressObject in _list) {
				p += o.percent;
			}
			percent = p / _list.length;
			return _percent;
		}

		override public function getObject() : * {
			return vectorToArray(_list);
		}

		public static function isValid($o : Array) : Boolean {
			for each (var o : * in $o) {
				if(!LoaderProgressObject.isValid(o) && !LoaderProgressObjectByteConverter.isValid(o)) {
					return false;
				}
			}
			return true;
		}

		override public function toString() : String {return "[" + getQualifiedClassName(this) + "] ";}
	}
}
