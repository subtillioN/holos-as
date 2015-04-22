/**
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
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.profiler.showRedrawRegions;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import sz.obj.ObjectPool_old;

	public class DisplayPool_old extends ObjectPool_old {
		protected var _displayList : Array;
		protected var _parent : DisplayObjectContainer;

		/**
		 * called on the update of the display list
		 */
		public var onUpdateDisplay : Function;
		/**
		 * determines the number of items to cycle
		 */
		public var cycleAmount : int = 1;

		public function DisplayPool_old($parent : DisplayObjectContainer, $type : Class = null, $updateHandler : Function = null, $size : Number = NaN, $fixed : Boolean = false, $initPool : Boolean = false, ...params)
		{
			super($type, $size, $fixed, $initPool, params);
			updateContext($parent, $updateHandler);
			_displayList = [];
		}


		override public function initPool($type : Class = null, $size : Number = NaN, $fixed : Boolean = false, ... params) : void
		{
			drain();
			super.initPool($type, $size, $fixed, params);
			_updateDisplay();
		}

		private function _getAll() : Array
		{
			return _displayList.concat(_pool);
		}

		public function display($amount : uint, ...params) : void
		{
			_displayList = _displayList.concat(takeMore($amount, params));
			_updateDisplay();
		}

		public function displayAt($index : int) : void
		{
			_displayList.push(takeAt($index));
			_updateDisplay();
		}

		public function hideObject($object : *) : void
		{
			_pool.put($object);
			_updateDisplay();
		}

		public function hideAt($index : int) : void
		{
			hideObject(_displayList.splice($index+1,1));
			_updateDisplay();
		}

		public function cycle($forward : Boolean = true, $cycleAmount : int = 0) : void
		{
			if($cycleAmount) cycleAmount = $cycleAmount;
			trace('   ' + this + '_pool = ' + _pool);
			trace('   ' + this + '_displayList = ' + _displayList);
			if($forward) {
				hide(cycleAmount);
				trace('AFTER HIDE  ________________________________________________________________________________');
				trace('   ' + this + '_pool = ' + _pool);
				trace('   ' + this + '_displayList = ' + _displayList);
				display(cycleAmount);
				trace('AFTER DISPLAY   ________________________________________________________________________________');
				trace('   ' + this + '_pool = ' + _pool);
				trace('   ' + this + '_displayList = ' + _displayList);
			}
			else
			{
				hideAt(0);
				displayAt(_displayList.length-1);
			}
		}


		public function hide($amount : int = -1) : void
		{
			trace(this + 'hide ');
			trace('   ' + this + '$amount = ' + $amount);
			if($amount == -1)$amount = _displayList.length;
			putFromExternalArray(_displayList, $amount);
			_updateDisplay();
		}


		private function _updateDisplay() : void
		{
			for each (var p : DisplayObject in _pool) {
				if(_parent.contains(p))_parent.removeChild(p);
			}
			for each (var o : DisplayObject in _displayList) {
				_parent.addChild(o);
			}
			if(onUpdateDisplay != null)onUpdateDisplay();
		}


		//--------------------------------------------------------------------------
		//
		//  PROPS
		//
		//--------------------------------------------------------------------------

		/**
		 * The total number of created objects currently in use outside of the pool.
		 */
		public function get usageCount() : int
		{
			return _displayList.length;
		}

		/**
		 * The total number of unused thus wasted objects. Use the purge()
		 * method to compact the pool.
		 */
		public function get unusedCount() : int
		{
			return _totalAlive - usageCount;
		}

		public function get parent() : DisplayObjectContainer
		{
			return _parent;
		}

		public function updateContext($parent : DisplayObjectContainer, $displayCallback : Function = null) : void
		{
			_parent = $parent;
			if($displayCallback != null) onUpdateDisplay = $displayCallback;
		}

		public function get dList() : Array
		{
			return _displayList;
		}


		//--------------------------------------------------------------------------
		//
		//              ObjectPool Overrides
		//
		//--------------------------------------------------------------------------

		/**
		 * Maps a method call onto the items currently in the pool, with the option of iterating a property.
		 * @param $method
		 * @param $iProp
		 * @param $begin
		 * @param $interval
		 */
		override public function map($method : Function = null, $iProp : String = null, $begin : int = 0, $interval : int = 1, $isAscending : Boolean = true) : void
		{
			mapArray(_getAll(), $method, $iProp, $begin, $interval, $isAscending);
			//mapArray(_displayList, $method, $iProp, $begin+($interval*_pool.length), $interval);
		}

		override public function setProps($props : Object) : void
		{
			for each (var o : * in _getAll()) {
				_setProps(o, $props);
			}
		}


		/**
		 * Drains (and by default deletes and nulls) all objects in the pool Array.
		 */
		override public function drain() : void
		{
			hide();
			super.drain();
			_updateDisplay();
		}

		override public function cull($amount : Number, $clampSize : Boolean = true) : Array
		{
			$amount = Math.min(_totalAlive, $amount);
			var remainder : uint = Math.max(0, $amount - _pool.length);
			if(remainder) hide(remainder);
			super.cull($amount, $clampSize);
			_updateDisplay();
			return null;
		}

		override public function clampSize() : void
		{
			_max = _totalAlive;
		}

		override public function get totalAlive() : int {return _totalAlive;}

		override public function toString() : String
		{
			return "[DisplayPool] ";
		}
	}

}
