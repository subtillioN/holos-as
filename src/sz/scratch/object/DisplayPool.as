/**
 *
 * MAIN GOAL : To aid in the update and display of an ObjectPool, such as global updating of a list of objects,
 * paging through a list of data objects and updating the objects with the page data.
 *
 * DisplayPool extends ObjectPool to provide management of display integrated with the ObjectPool
 *
 * @author Joel Morrison
 * @version 1.0
 * @since 12.20.2010
 *
 */


package sz.scratch.object {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;

	import sz.holos.collections.Cursor;

	public class DisplayPool extends ObjectPoolH {
		protected var _parent : DisplayObjectContainer;
		private var _cursor : Cursor;
		private var _dataList : Array;

		/**
		 * called on the update of the display list
		 */
		public var onUpdateDisplay : Function;


		public function DisplayPool($parent : DisplayObjectContainer, $content : *, $updateHandler : Function = null, $max : Number = NaN, $fixed : Boolean = false, $initPool : Boolean = false, ...params)
		{
			super($content, $max, $fixed, $initPool, params);
			updateContext($parent, $updateHandler);
			onPoolUpdate = _updateDisplay;
		}


		public function displayObjects($amount : uint, ...params) : void
		{
			pullMore($amount, params);
		}

		public function hideObject($object : Object) : void
		{
			put($object);
		}

		public function cycle($amount : Number) : void
		{
			for(var i : int = 0; i < $amount; i++) {
				_put(_activeSet.pull());
				_pull();
			}
			onPoolUpdate();
		}


		public function recycle($object : Object) : void
		{
			_put($object);
			_pull();
			onPoolUpdate();
		}


		public function hideAmount($amount : int = -1) : void
		{
			trace(this + 'hideAmount ');
			trace('   ' + this + '$amount = ' + $amount);
			if($amount == -1)$amount = numActive;
			putMore($amount);
		}


		override public function drain() : void
		{
			hideAmount();
			super.drain();
		}

		private function _updateDisplay() : void
		{
			for each (var p : DisplayObject in inactiveList) {
				if(p is DisplayObject && _parent.contains(p))_parent.removeChild(p);
			}
			for each (var o : DisplayObject in activeList) {
				if(o is DisplayObject)_parent.addChild(o);
			}
			onUpdateDisplay();
		}

		//--------------------------------------------------------------------------
		//
		//  PROPS
		//
		//--------------------------------------------------------------------------

		public function get parent() : DisplayObjectContainer {return _parent;}

		public function updateContext($parent : DisplayObjectContainer, $displayCallback : Function = null) : void
		{
			_parent = $parent;
			if($displayCallback != null) {
				onUpdateDisplay = $displayCallback;
			}
			else {
				onUpdateDisplay = function() : void {};
			}
		}

		public function get displayList() : Array
		{
			return activeList;
		}

		override public function toString() : String {return "[DisplayPool] ";}
	}
}
