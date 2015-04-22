/**
 * Created by
 * User: jmorrison
 * Date: 12/13/10
 * Time: 10:31 AM
 *
 */
package sz.scratch.object {
	import sz.scratch.utils.*;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class ObjectPool_old {

		/**
		 * determines whether the size of the pool (or the total number of created objects) is fixed or can expand when taking from an empty pool
		 */
		public var fixed : Boolean;

		/**
		 * determines if the take (and cull) operation does a pop (default) or a shift
		 */
		public var isTakeOrderFILO : Boolean = false;

		/**
		 * determines if the put operation does a push (default) or an unshift
		 */
		public var isPutOrderFILO : Boolean = true;

		/**
		 * The parameters array with which to initialize each object
		 */
		public var initParams : Array;

		/**
		 * Callback for when new objects are created
		 */
		public var onCreateObject : Function;

		/**
		 * Callback for when new objects are successfully pulled or taken from the pool
		 */
		public var onPullObject : Function;

		/**
		 * Callback for when objects are put in or returned to the pool
		 */
		public var onPutObject : Function;

		/**
		 * Callback for when objects are culled from the pool and not returned to the user, effectively deleted
		 */
		public var onCullObject : Function;


		protected var _max : Number;
		protected var _type : Class;
		protected var _pool : Array;
		protected var _totalAlive : int;


		public function ObjectPool_old($type : Class = null, $max : Number = NaN, $fixed : Boolean = false, $initPool : Boolean = false, ...params)
		{
			_type = $type;
			_pool = [];
			onCreateObject = onPullObject = onPutObject = onCullObject = function(obj : Object) : void {};
			if(!isNaN($max) && $initPool) {
				initPool($type, $max, $fixed, params);
			}
		}

		/**
		 * Initializes a pool
		 *
		 * @param $type The type of object required.
		 * @param params The params to pass into construct.
		 */
		public function initPool($type : Class = null, $size : Number = NaN, $fixed : Boolean = false, ...params) : void
		{
			initParams = params;
			if(!$type && !_type) {
				trace(this + 'ERROR : Must specify a type either in constructor or init');
				return;
			}
			if($type) _type = $type;
			fixed = $fixed;
			trace(this + 'params = ' + params);
			_max = $size;
			if(_pool.length)drain();//already initialized

			for(var i : int = 0; i < $size; i++) {
				_pool.push(_createObject(_type, initParams));
			}
			_totalAlive = _pool.length;
		}

		private function _createObject($type : Class, ...params) : *
		{
			var o : * = construct(_type, params);
			onCreateObject(o);
			return o;
		}


		// --- TAKE : REMOVE AND RETURN OBJECTS TO USER --- //

		/**
		 * Get an object of the specified $type. If such an object exists in the pool then
		 * it will be returned. If such an object doesn't exist, a new one will be created.
		 *
		 * @param params If there are no instances of the object in the pool, a new one
		 * will be created and these parameters will be passed to the object constrictor.
		 * Because you can't know if a new object will be created, you can't rely on these
		 * parameters being used. They are here to enable pooling of objects that require
		 * parameters in their constructor.
		 */
		public function pull(...params) : *
		{
			if(params + '' == '')params = initParams;
			var o : *;
			if(_pool.length > 0) {
				o = takeNext(isTakeOrderFILO);
				onPullObject(o);
				return o;
			}
			else {
				if(fixed) {
					if(_totalAlive < _max) {
						_totalAlive++;
						o = _createObject(_type, params);
						onPullObject(o);
						return o;
					}
					trace(this + 'fixed pool is empty');
				}
				else if(!fixed) {
					_totalAlive++;
					trace(this + 'NOT FIXED, constructing new ' + _type + " with params : " + params);
					o = _createObject(_type, params);
					onPullObject(o);
					return o;
				}
			}
			trace(this + 'Failed to take object of type ' + _type);
			return null;
		}


		/**
		 * Get an object of the specified $type. If such an object exists in the pool then
		 * it will be returned. If such an object doesn't exist, a new one will be created.
		 *
		 * @param $type The type of object required.
		 * @param params If there are no instances of the object in the pool, a new one
		 * will be created and these parameters will be passed to the object constrictor.
		 * Because you can't know if a new object will be created, you can't rely on these
		 * parameters being used. They are here to enable pooling of objects that require
		 * parameters in their constructor.
		 */
		public function takeMore($amount : uint, ...params) : Array
		{
			var a : Array = [];
			var o : *;
			for(var i : int = 0; i < $amount; i++) {
				o = pull(params);
				if(o) a.push(o);
			}
			return a;
		}

		public function takeAt($index : int) : *
		{
			return _pool.splice($index, 1)[0];
		}

		public function takeAll() : Array
		{
			return takeMore(_pool.length);
		}


		// --- PUT : RETURN OBJECTS TO POOL --- //

		/**
		 * Return an object to the pool for retention and later reuse. Note that the object
		 * still exists, so you need to clean up any event listeners etc. on the object so
		 * that the events stop occurring.
		 *
		 * @param object The object to return to the object pool.
		 * @param $type The type of the object. If you don't indicate the object type then the
		 * object is inspected to find its type. This is a little slower than specifying the
		 * type yourself.
		 */
		public function put($object : *) : void
		{
			var $i : int = isPutOrderFILO ? _pool.length : 0;
			if((fixed && _pool.length < _max) || !fixed) {
				putAt($object, $i);
			}
		}

		public function putAt($object : *, $index : int) : void
		{
			trace(this + 'putAt ');

			if(!_checkType($object))return;
			if($index < 0) {
				$index = Math.max(0, _pool.length + $index + 1);
			}
			else {
				$index = Math.min(_pool.length, $index);
			}
			onPutObject($object);
			trace('   ' + this + '$index = ' + $index);
			_pool.splice($index, 0, $object);
		}

		/**
		 * returns to the pool the specified number of items from the array.
		 * NOTE: If using automatic displaylist handling, use hide() instead.
		 * @param $fromArray
		 * @param $amount
		 * @param $map
		 */
		public function putFromExternalArray($fromArray : Array, $amount : int = -1) : Array
		{
			trace(this + 'putFromExternalArray ');
			if($amount == -1)$amount = $fromArray.length;
			var o : *;
			for(var i : int = 0; i < $amount; i++) {
				o = $fromArray.pop();
				trace('   ' + this + 'o = ' + o);
				put(o);
			}
			return $fromArray;
		}


		// --- CULL : REMOVE OBJECTS FROM POOL WITHOUT RETURNING TO THE USER --- //

		public function cull($amount : Number, $clampSize : Boolean = true) : Array
		{
			var a : Array = [];
			$amount = Math.min(_pool.length, $amount);
			var o : *;
			for(var i : int = 0; i < $amount; i++) {
				o = takeNext(isPutOrderFILO);
				onCullObject(o);
				a.push(o);
				_totalAlive--;
			}
			if($clampSize)clampSize();
			return a;
		}

		public function cullTo($size : Number) : void
		{
			_max = $size;
			if(_pool.length > _max) cull(_pool.length - _max);
		}

		/**
		 * Drains (and by default deletes and nulls) all objects in the pool Array.
		 */
		public function drain() : void
		{
			cull(_totalAlive);
		}


		// --- ITERATE --- //

		public function takeNext($isFILO : Boolean = true) : *
		{
			if($isFILO) return pop();
			return shift();
		}

		public function push($o : *) : void
		{
			putAt($o, _pool.length - 1);
		}

		public function pop() : *
		{
			return takeAt(_pool.length - 1);
		}

		public function unshift($o : *) : void
		{
			putAt($o, 0);
		}

		public function shift() : *
		{
			return takeAt(0);
		}


		// --- MAP --- //

		/**
		 * Maps a method call onto the items currently in the pool, with the option of iterating a property.
		 * @param $method
		 * @param $iProp
		 * @param $begin
		 * @param $interval
		 */
		public function map($method : Function = null, $iProp : String = null, $begin : int = 0, $interval : int = 1, $isAscending : Boolean = true) : void
		{
			mapArray(_pool, $method, $iProp, $begin, $interval);
		}

		public function mapArray($a : Array, $method : Function, $iProp : String, $begin : int, $interval : int, $isAscending : Boolean = true) : void
		{
			trace(this + 'mapArray ');
			var i : int;
			if($isAscending) {
				i = $begin;
			}
			else {
				i = $begin + ($interval * _pool.length) - $interval;
				$interval = -$interval;
			}
			for each (var o : * in _pool) {
				if($iProp) {
					try {
						o[$iProp] = i;
						i = i + $interval;
					} catch(error : Error) {
						trace("Error catch: " + error);
						trace(this + "can't iterate over enumProp " + $iProp);
					}
				}
				if($method != null) {
					try {
						$method(o);
					} catch(error : Error) {
						trace("Error catch: " + error);
						trace(this + "can't map over method " + $method);
					}
				}
			}
		}


		// --- PROPS --- //

		public function setProps($props : Object) : void
		{
			for each (var o : * in _pool) {
				_setProps(o, $props);
			}
		}

		protected function _setProps($object : *, $props : Object) : void
		{
			for(var key : Object in $props) {
				try {
					$object[key] = $props[key];
				} catch(error : Error) {
					trace(this + "setProps error: " + $object + ' for ' + key);
				} finally {
				}
			}
		}

		public function clampSize() : void
		{
			_max = _totalAlive;
			trace('   ' + this + '_size = ' + _max);
		}

		protected function _checkType($object : *) : Boolean
		{
			if(!$object)return false;
			var typeName : String = getQualifiedClassName($object);
			var testType : Class = getDefinitionByName(typeName) as Class;
			if(_type != testType) {
				trace(this + 'ERROR : object type ' + typeName + ' does not equal the set type for this pool : ' + _type);
				return false;
			}
			return true;
		}

		//--------------------------------------------------------------------------
		//
		//  PROPS
		//
		//--------------------------------------------------------------------------

		public function getSize() : Number {return _pool.length;}

		public function get type() : Class
		{
			return _type;
		}

		public function get totalAlive() : int {return _totalAlive;}

		public function get pool() : Array
		{
			return _pool.concat();
		}

		public function toString() : String
		{
			return "[ObjectPool] ";
		}
	}
}
