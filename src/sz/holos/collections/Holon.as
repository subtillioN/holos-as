package sz.holos.collections {
	import flash.utils.Dictionary;

	/**
	 * Holon is the recursive unit class (holon : part-whole, and whole made of parts) for the HoloModel (holarchy model)
	 *
	 * @see HoloModel
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 2/8/11
	 *
	 */
	public class Holon {
		public var id : String = "ROOT";
		public var parent : Holon;
		public var childMap : Dictionary;
		public var data : *;
		public var numChildren : uint = 0;
		private var _depth : int;
		private var _children : Vector.<Holon>;
		private var _cursor : Cursor;
		private var _nodeAddress : Vector.<uint>;
		private var _nodePath : Vector.<Holon>;
		private var _nodeIDPath : Vector.<String>;
		private var _totalDepth : uint = 0;
		private var _defaultIndex : uint = 0;
		public var index : int;
		// --- buffers --- //
		public var nodeCursor : Holon;
		private var _n : Holon;


		// ------ PARSE AND SET UP ----------------------------------------------------------------------------- //

		public static function parse($x : XML, $parent : Holon = null) : Holon {
			var u : Holon = new Holon();
			if($x.@id != undefined)u.id = $x.@id + '';
			if($parent) {
				u.parent = $parent;
				u.depth = u.parent.depth + 1;
			} else u.depth = 0;
			u.parseChildren($x.node, u);
			u.numChildren = u._children.length;
			u.setupCursor(u._children.length, $x.@loopChildren + '' != 'false');
			if($x.data != undefined) {
				var dx : XML = new XML($x.data.toString());
				if(dx.@id == undefined)dx.@id = u.id;
				if(dx.@path == undefined)dx.@path = u.nodeIDPath;
				u.data = dx;
			}
			return u;
		}

		public function parseChildren($xl : XMLList, $parent : Holon) : void {
			_children = new Vector.<Holon>();
			childMap = new Dictionary(true);
			var i : int = 0;
			for each (var x : XML in $xl) {
				_n = Holon.parse(x, $parent);
				_n.index = i;
				_children.push(_n);
				childMap[_n.id] = _n;
				i++;
			}
		}

		/**
		 * e.g.
		 * function sectionParser($x : *):SectionVO{
		 *    var vo : SectionVO = new SectionVO();
		 *	  trace('' + '$x = ' + $x);
		 *	  if($x)vo.parse($x);
		 *	  return vo ;
		 * }
		 *
		 * ////
		 *
		 * _holoModel.parse(_xml, sectionParser);
		 *
		 * @param $parser
		 */
		public function parseData($parser : Function) : void {
			data = $parser(data);
			for each (_n in _children) {
				_n.parseData($parser);
			}
		}

		public function setupCursor($length : uint, $loop : Boolean, $defaultIndex : uint = 0) : void {
			_cursor = new Cursor($length - 1, 0, $loop);
			_defaultIndex = $defaultIndex;
		}

		// ------ NAVIGATION ----------------------------------------------------------------------------- //

		public function hasPrev() : Boolean {
			return _cursor.hasPrev;
		}

		public function hasNext() : Boolean {
			return _cursor.hasNext;
		}

		public function prev() : Holon {
			return childAt(_cursor.prev);
		}

		public function next() : Holon {
			return childAt(_cursor.next);
		}

		public function childAt($pos : uint) : Holon {
			_cursor.at($pos);
			return selectedChild;
		}

		public function childByID($id : String) : Holon {
			nodeCursor = childMap[$id];
			if(nodeCursor) {
				_cursor.at(nodeCursor.index);
				return nodeCursor;
			}
			return null;
		}

		public function childIndexByID($id : String) : uint {
			if(childByID($id))return selectedChild.index;
			return null;
		}

		public function setAddress($address : Vector.<uint>) : void {
			if(numChildren) {
				if(!$address.length)$address.push(_defaultIndex);
				var i : uint = $address.shift();
				nodeCursor = childAt(i);
				if(nodeCursor)nodeCursor.setAddress($address);
			}
		}


		public function setAddressFromPath($path : Vector.<String>) : void {
			if(numChildren) {
				var s : String = $path.shift();
				nodeCursor = childByID(s);
				if(nodeCursor)nodeCursor.setAddressFromPath($path);
			}
		}

		// ------ DATA, ADDRESSES, PATHS, RESOLVERS ----------------------------------------------------------------------------- //

		public function get nodeAddress() : Vector.<uint> {
			if(!_nodeAddress) {
				_nodeAddress = new Vector.<uint>();
				_n = this;
				while(_n.parent) {
					_nodeAddress.unshift(_n.index);
					_n = _n.parent;
				}
			}
			return _nodeAddress;
		}


		public function get cursorAddress() : Vector.<uint> {
			return bottomChild.nodeAddress;
		}

		public function get nodeIDPath() : Vector.<String> {
			if(!_nodeIDPath) {
				_nodeIDPath = new Vector.<String>();
				_n = this;
				while(_n.parent) {
					_nodeIDPath.push(_n.id);
					_n = _n.parent;
				}
				_nodeIDPath.reverse();
			}
			return _nodeIDPath;
		}


		public function get nodePath() : Vector.<Holon> {
			if(!_nodePath) {
				_nodePath = new Vector.<Holon>();
				_n = this;
				while(_n.parent) {
					_nodePath.push(_n);
					_n = _n.parent;
				}
				_nodePath.reverse();
			}
			return _nodePath;
		}

		public function set depth($depth : uint) : void {
			_depth = $depth;
			root.totalDepth = _depth;
		}

		public function set totalDepth($depth : uint) : void {
			_totalDepth = Math.max(_totalDepth, $depth);
		}

		public function get cursorPath() : Vector.<String> {
			return bottomChild.nodeIDPath;
		}

		public function get bottomChild() : Holon {
			_n = this;
			while(_n.selectedChild) {
				_n = _n.selectedChild;
			}
			return _n;
		}

		public function get root() : Holon {
			_n = this;
			while(_n.parent) {
				_n = _n.parent;
			}
			return _n;
		}

		public function get selectedChild() : Holon {
			if(!numChildren)return null;
			return _children[_cursor.i];
		}


		public function get depth() : uint {return _depth;}

		public function get totalDepth() : uint {return _totalDepth;}

		public function toString() : String {return "[Holon] " + id + " :: ";}
	}
}