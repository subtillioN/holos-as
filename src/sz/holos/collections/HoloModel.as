/**
 * MAIN GOAL:
 * To automate and externalize the modeling, management and wiring of hierarchical navigational structure, logic, and
 * data for a site or module.  Loosely speaking, a simplistic dendritic modular central nervous system for state
 * control. HoloModel automates the construction of a simply-visualized (XML), unified logic structure or skeleton of
 * action, while removing human error and tedium in ad hoc wiring this structure by hand.  And so it can greatly speed
 * up production by placing the site-logic development work in the XML model, with its ready and easy hierarchical
 * structure and malleability.
 *
 * HoloModel is a general purpose, addressable model or option-space micro-framework for hierarchical (or holarchical)
 * data management, 2-D navigation, and manipulation (so far both linear (common) iteration and depth in the
 * tree). HoloModel has a modular and recursive payload parsing set-up and is easily extended for tree models of a
 * general sort (limited to linear paths and operations (e.g. URI spaces), currently, and a static or absolute
 * state-space, once the parsing has completed...i.e. you can't shuffle the units around in their address-space)...
 *
 * HoloModel will parse the XML model and build the tree for you, while exposing methods for drilling into the
 * addressable units, and customizing and generating whatever control data you wish to work on in navigating through
 * the model.  It exposes a simple api for binding to String and int "cursor list" Arrays for building, as well as
 * handling internal navigation, via both vector addresses (e.g. [3,0,2]) and paths (e.g. [section3, page0, tab2], or
 * mysite.html/#section1).
 *
 * SETUP
 * Once the XML model is defined and loaded, it just needs to be passed into the parser to generate the hierarchical
 * logic and data structure.  The data in the data XML nodes will be dumped into the generic-typed 'data:*' property
 * instance of the specific node (Holon).  You can inject your own parser (or type-adapter) into the parsing process to
 * translate the 'data' XML into your required objects, which can be of any and varied object type throughout the system,
 * depending only on the logic of the parsing adapter. Note that the Holon parser automatically injects the Holon 'id'
 * and 'path' (e.g. 'main/images/01' as an attribute on the root of the data node. To override that, just add your own
 * values in the XML.  See Holon for parsing details.
 *
 * MODEL
 * To retrieve the current position (cursor) in the option-space located in the navigation process (e.g. targeting a
 * specific URL), you can either use the various cursorList getters on HoloModel(e.g. cursorListString, or
 * cursorListData), or you can register callbacks for their values (Arrays) upon change of the cursor list.
 *
 * API
 * The navigational API consists of 2-D navigational 'go*' calls such as 'goNextAt({depth})', 'goPrevAt({depth})',
 * 'gotoAddress({address array})', etc.  In general, 'address' refers to the 'physical' or Vector.<int> address,
 * such as 3,1,7.  And 'path' refers to the human readable IDs representing the units in the address, such as a URL.
 *
 * STRUCTURE KEY
 *  Paths and Addresses : In general, addresses are the quick navigational URI used throughout the structure, and the
 *  paths are the human-readable values tucked inside every unit of the system.  Every time a unit is retrieved, the
 *  path of selection is retained in a buffer (unitCursor) which can be traversed to retrieve (or inverted to address)
 *  the unit-holon and its payload.
 *    Address : Vector uint address for each node, from origin or root to current position, where length corresponds
 *      to depth in the tree.
 *    Path : the id string, or human readable
 *    Data : a slot in the framework for automating the customization of the structure on a per node basis, by plugging
 *      into the xml structure your parser to convert the dada node XML into whatever objects you want inserted to the
 *      'data' property of the Holon instance  in the model. Very flexible, combined with the methods for retrieving
 *      these sets of data packets.
 *
 *
 * // TODO :: Implement set generator algorithms for various slices or views e.g. linearization, for the various
 *      data types, e.g.
 *
 * ex XML
 *
 * <root loopChildren="false">
 *     <node id="a1">
 *         <data>
 *             <title>SECTION ONE</title>
 *             <body>blah blah blah</body>
 *         </data>
 *         <node id="b1">
 *             <node id="c1">
 *             </node>
 *             <node id="c2">
 *             </node>
 *             <node id="c3">
 *             </node>
 *         </node>
 *         <node id="b2" loopChildren="false">
 *             <node id="c4">
 *             </node>
 *             <node id="c5">
 *             </node>
 *             <node id="c6">
 *             </node>
 *         </node>
 *         <node id="b3">
 *         </node>
 *     </node>
 * </root>
 *
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
 *
 *
 * @see Holon, and DeepAddress
 *
 * @author Joel Morrison
 * @version 1.0
 * @since 2/8/11
 *
 */
package sz.holos.collections {
	import sz.holos.type.utils.arrayToVector;
	import sz.holos.func.runAll;

	public class HoloModel {
		private var _root : Holon;
		private var _depthCursor : Holon;
		private var _totalDepth : int = 0;
		private var _cursorListAddress : Vector.<uint>;
		private var _cursorListString : Vector.<String>;
		private var _prefix : String = "";
		private var _suffix : String = "";
		private var _delimiter : String = "/";

		// --- callbacks --- //
		private var _onCursorUpdate : Vector.<Function>;
		private var _onCursorListStringUpdate : Vector.<Function>;
		private var _onCursorListDataUpdate : Vector.<Function>;
		private var _onCursorListAddressUpdate : Vector.<Function>;
		private var _onCursorListUpdate : Vector.<Function>;
		private var _cursorListUnitProcessor : Function;


		// TODO : Implement silent mode, for traversing tree without triggering calls, for grabbing data, etc. Just save current address and reset when complete.

		public function HoloModel() {
			_cursorListAddress = new Vector.<uint>();
		}

		public function parse($data : XML) : void {
			_root = Holon.parse($data);
			_totalDepth = _root.totalDepth;
		}

		// ------ NAVIGATION ----------------------------------------------------------------------------- //

		public function prevAt($depth : int = 0) : void {
			_setTreeCursor($depth).prev();
			call();
		}

		public function nextAt($depth : int = 0) : void {
			_setTreeCursor($depth).next();
			call()
		}

		public function hasPrevAt($depth : int = 0) : Boolean {
			return _setTreeCursor($depth).hasPrev();
		}

		public function hasNextAt($depth : int = 0) : Boolean {
			return _setTreeCursor($depth).hasNext();
		}

		/**
		 * @param $address  zero-based int tree address e.g. [0,3,2]
		 * where this would be the 3nd node of the 4th node of the 1st node under the root
		 */
		public function setAddressNumFromArray($address : Array) : void {
			arrayToVector($address, _cursorListAddress);
			_root.setAddress(_cursorListAddress);
			call();
		}

		// ------ CALL ... BACK ----------------------------------------------------------------------------- //

		public function call() : void {
			_trace(this + 'call ');
			runAll(_onCursorUpdate);
			runAll(_onCursorListUpdate, cursorPathArray);
			runAll(_onCursorListAddressUpdate, cursorListAddress);
			runAll(_onCursorListStringUpdate, cursorListString);
			runAll(_onCursorListDataUpdate, cursorPathData);
			report("call()");
		}

		private function _error($s : String) : void {
			_trace(this + 'ERROR :: ' + $s);
		}

		public function report($s : String = '') : void {
			_trace(this + " :: REPORT ...\r" + $s + '\r' + 'address = ' + cursorListAddress);
			_trace('' + 'path = ' + cursorListString + "\r\r");
		}


		// ------ HELPERS ----------------------------------------------------------------------------- //


		private function _setTreeCursor($depth : int) : Holon {
			_depthCursor = _root;
			var i : int = 0;
			while($depth > i) {
				_depthCursor = _depthCursor.selectedChild;
				_trace('l.id = ' + _depthCursor.id);
				i++;
			}
			return _depthCursor;
		}


		// ------ GETTERS AND SETTERS ----------------------------------------------------------------------------- //

		public function get cursorListAddress() : Vector.<uint> {
			return _root.cursorAddress;
		}

		public function get cursorPathArray() : Array {
			return _root.cursorPath.join(",").split(",");
		}

		public function get cursorPathData() : Array {
			var a : Array = [];
			for each (var n : Holon in _root.bottomChild.nodePath) {
				a.push(n.data);
			}
			return a;
		}

		public function get cursorListString() : String {
			var a : Array = [];
			if(_cursorListUnitProcessor != null) {
				for each (var s : String in cursorPathArray) {
					a.push(_cursorListUnitProcessor(s));
				}
			} else a = cursorPathArray;
			return _prefix + a.join(_delimiter) + _suffix;
		}

		public function get prefix() : String {
			return _prefix;
		}

		public function set prefix(value : String) : void {
			_prefix = value;
		}

		public function get suffix() : String {
			return _suffix;
		}

		public function set suffix(value : String) : void {
			_suffix = value;
		}

		public function get delimiter() : String {
			return _delimiter;
		}

		public function set delimiter(value : String) : void {
			_delimiter = value;
		}

		public function get depthCursor() : Holon {
			return _depthCursor;
		}

		public function get totalDepth() : int {
			return _root.totalDepth;
		}

		// --- callback setters --- //

		public function set onCursorUpdate(value : Function) : void {
			if(!_onCursorUpdate)_onCursorUpdate = new Vector.<Function>();
			_onCursorUpdate.push(value);
		}


		public function set onCursorListDataUpdate(value : Function) : void {
			if(!_onCursorListDataUpdate)_onCursorListDataUpdate = new Vector.<Function>();
			_onCursorListDataUpdate.push(value);
		}

		public function set onCursorListStringUpdate(value : Function) : void {
			if(!_onCursorListStringUpdate)_onCursorListStringUpdate = new Vector.<Function>();
			_onCursorListStringUpdate.push(value);
		}

		public function set onCursorListAddressUpdate(value : Function) : void {
			if(!_onCursorListAddressUpdate)_onCursorListAddressUpdate = new Vector.<Function>();
			_onCursorListAddressUpdate.push(value);
		}

		public function set onCursorListUpdate($f : Function) : void {
			if(!_onCursorListUpdate)_onCursorListUpdate = new Vector.<Function>();
			_onCursorListUpdate.push($f);
		}

		public function set cursorListUnitProcessor(value : Function) : void {
			_cursorListUnitProcessor = value;
		}

		// --- misc --- //

		public function parseData($parser : Function) : void {_root.parseData($parser)}

		public function get root() : Holon {return _root;}

		private function _trace(...rest) : void {
			//trace(rest);
		}

		public function setAddressFromPath($path : Vector.<String>) : void {
			_root.setAddressFromPath($path);
			call();
		}

		public function setAddressFromPathArray($a : Array) : void {
			arrayToVector($a, _cursorListString);
			setAddressFromPath(_cursorListString);
			call();
		}

		public function getPathArrayFromAddress($address : Array) : Array {
			arrayToVector($address, _cursorListAddress);
			_root.setAddress(_cursorListAddress);
			return cursorPathArray;
		}

		public function toString() : String {
			return "[HoloModel] ";
		}
	}
}
