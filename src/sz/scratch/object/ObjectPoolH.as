/**
 * User: jmorrison
 * Date: 12/13/10
 * Time: 10:31 AM
 */
package sz.scratch.object {
	import sz.scratch.utils.construct;

	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class ObjectPoolH {

		/**
		 * determines whether the size of the pool (or the total number of created objects) is fixed or can expand when taking from an empty pool
		 */
		public var fixed : Boolean;

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

		/**
		 * Callback for when objects are released (returned to the pool)
		 */
		public var onPoolUpdate : Function;

		private var _classList : Array;
		protected var _max : Number;
		protected var _activeSet : ObjectSet;
		protected var _inactiveSet : ObjectSet;
		protected var _createFromListRandom : Boolean = false;
		private var _currentClassIndex : int = -1;
		private var _content : *;


		public function ObjectPoolH($content : *, $max : Number = NaN, $fixed : Boolean = false, $initPool : Boolean = false, ...params)
		{
			if(!$content)return;
			_content = $content;
			_activeSet = new ObjectSet();
			_inactiveSet = new ObjectSet();
			_activeSet.id = "active";
			_inactiveSet.id = "inactive";
			onCreateObject = onPullObject = onPutObject = onCullObject = function(obj : Object) : void {};
			onPoolUpdate = function() : void {};
			if(!isNaN($max) && $initPool) {
				initPool(_classList, $max, $fixed, params);
			}
		}

		/**
		 * Initializes a pool
		 *
		 * @param $type The type of object required.
		 * @param params The params to pass into construct.
		 */
		public function initPool($content : *, $max : Number = NaN, $fixed : Boolean = false, ...params) : void
		{
			if($content) _content = $content;
			if(_content is Class) {
				_classList = [_content as Class];
			} else if(_content is Array) {
				_classList = _content as Array;
			} else if(!_content) {
				throw new Error("Bad argument passed to ObjectPool. First argument must be class or array of classes");
			}
			initParams = params;
			fixed = $fixed;
			trace(this + 'params = ' + params);
			_max = $max;
			if(numAlive)drain();//already initialized

			for(var i : int = 0; i < $max; i++) {
				_inactiveSet.put(_createNextObject(initParams));
			}
		}

		private function _createNextObject($params : Array) : Object
		{
			if(!_classList.length)return _create(_classList[0]);
			if(_createFromListRandom) {
				return _createObjectRandom();
			}
			else {
				return _createObjectSequential();
			}
		}

		private function _createObjectRandom() : Object
		{
			var i : int = int(Math.random() * _classList.length);
			return _create(_classList[i]);
		}

		private function _createObjectSequential() : Object
		{
			++_currentClassIndex;
			if(_currentClassIndex >= _classList.length)_currentClassIndex = 0;
			return _create(_classList[_currentClassIndex]);
		}


		private function _create($type : Class) : Object
		{
			var o : * = construct($type, initParams);
			onCreateObject(o);
//			++_numAlive;
			return o;
		}


		// --- TAKE : REMOVE AND RETURN OBJECTS TO USER --- //

		protected function _pull($sneak : Boolean = false, ...params) : Object
		{
			if(params + '' == '')params = initParams;
			var obj : Object;

			if(_inactiveSet.length > 0) {
				obj = _inactiveSet.pull();
				_activeSet.put(obj);
				onPullObject(obj);
				if(!$sneak)onPoolUpdate();

				return obj;
			} else if(numAlive < _max) {
				obj = _createNextObject(params);
//				++_totalAlive;
				_activeSet.put(obj);
//				onCreateObject(obj);
				onPullObject(obj);
				if(!$sneak)onPoolUpdate();
				return obj;
			} else {
				return null;
			}
		}

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
		public function pull(...params) : Object
		{
			var o : Object = _pull(false, params);
			onPoolUpdate();
			return o;
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
		public function pullMore($amount : uint, ...params) : Array
		{
			var a : Array = [];
			var o : *;
			for(var i : int = 0; i < $amount; i++) {
				o = _pull(true, params);
				if(o) a.push(o);
			}
			onPoolUpdate();
			return a;
		}


		public function pullAll() : Array
		{
			return pullMore(_inactiveSet.length);
		}


		// --- PUT : RETURN OBJECTS TO POOL --- //

		protected function _put($object : Object, $sneak : Boolean = false) : Boolean
		{
			if(_activeSet.cull($object)) {
				_inactiveSet.put($object);
				onPutObject($object);
				if(!$sneak)onPoolUpdate();
				return true;
			} else {
				return false;
			}
		}

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
		public function put($object : Object) : Boolean
		{
			return _put($object);
		}

		public function putMore($amount : uint) : void
		{
			$amount = Math.min($amount, _activeSet.length);
			for(var i : int = 0; i < $amount; i++) {
				_put(_activeSet.tail, true);
			}
			onPoolUpdate();
		}


		// --- CULL : REMOVE OBJECTS FROM POOL WITHOUT RETURNING TO THE USER --- //


		public function cull($amount : Number, $clampSize : Boolean = true) : void
		{
			var xtraAmount : uint = $amount - _inactiveSet.length;
			$amount = Math.min(_inactiveSet.length, $amount);
			var o : *;
			for(var i : int = 0; i < $amount; i++) {
				o = _pull();
//				_numAlive--;
				onCullObject(o);
			}
			if(xtraAmount) {
				for(var j : int = 0; j < xtraAmount; j++) {
					o = _activeSet.pull();
//					_numAlive--;
					onCullObject(o);
				}
			}
			if($clampSize)clampMax();
			onPoolUpdate();
		}

		public function cullTo($size : Number) : Boolean
		{
			_max = $size;
			if(_inactiveSet.length > _max) {
				cull(_inactiveSet.length - _max);
				return true;
			}
			return false;
		}

		/**
		 * Drains (and by default deletes and nulls) all objects in the pool Array.
		 */
		public function drain() : void
		{
			cull(numAlive);
			_activeSet.destroy();
			_inactiveSet.destroy();
			onPoolUpdate();
		}


		// --- ITERATE --- //

		/**
		 * returns a reference to the next object
		 * @param $object
		 * @return
		 */
		public function getNext($object : Object) : Object
		{
			var o : Object;
			o = _activeSet.getNext($object);
			if(!o)o = _inactiveSet.getNext($object);
			return o;
		}

		/**
		 * returns a reference to the previous object
		 * @param $object
		 * @return
		 */
		public function getPrevious($object : Object) : Object
		{
			var o : Object;
			o = _activeSet.getPrevious($object);
			if(!o)o = _inactiveSet.getPrevious($object);
			return o;
		}


		// --- ITERATE --- //

		/**
		 * Maps a method call onto the items currently in the pool, with the option of iterating a property.
		 * @param $method
		 * @param $iProp
		 * @param $begin
		 * @param $interval
		 * @param $isAscending
		 */
		public function iterate($method : Function = null, $iProp : String = null, $begin : int = 0, $interval : int = 1, $isAscending : Boolean = true) : void
		{
			_activeSet.iterate($method, $iProp, $begin, $interval, $isAscending);
			_inactiveSet.iterate($method, $iProp, $begin * $interval, $interval, $isAscending);
		}


		// --- PROPS --- //

		public function setProps($props : Object) : void
		{
			for each (var o : * in _activeSet.list) {
				_setProps(o, $props);
			}
			for each (var o : * in _inactiveSet.list) {
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


		public function clampMax() : void
		{
			_max = numAlive;
			trace('   ' + this + '_max = ' + _max);
		}





		//--------------------------------------------------------------------------
		//
		//  PROPS
		//
		//--------------------------------------------------------------------------

		public function getMax() : Number {return _max;}


		public function get numAlive() : int {return numInactive + numActive;}

		public function get numActive() : int {return _activeSet.length;}

		public function get numInactive() : int {return _inactiveSet.length;}

		public function get activeList() : Array{return _activeSet.list.concat();}

		public function get inactiveList() : Array{return _activeSet.list.concat();}

		public function get totalList() : Array{return _activeSet.list.concat(_inactiveSet.list);}

		public function toString() : String{return "[ObjectPool] ";}
	}
}


