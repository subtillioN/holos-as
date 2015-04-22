package sz.holos.config {
	import com.core.binding.Binder;
	import com.core.commands.data.XMLCall;
	import com.core.loaders.ImagePreloader;
	import com.core.loaders.LibraryLoader;
	import com.core.loading.LoadGroup;
	import com.core.loading.LoadItem;
	import com.core.utils.FBtrace;

	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;

	import sz.holos.type.ParseTypes;
	import sz.holos.reflect.Introspect;
	import sz.holos.vo.LoadVO;

	/**
	 * R(esources): A central XML data spine, Static class, for an application using simple auto-parsing, auto-indexing
	 * dictionaries for quickly externalizing a global model of typed values and resources in the XML.
	 * These include external xml, booleans, ints, strings, and numbers, and LoadGroups of SWFs and images etc ...
	 * for now.  R is mainly used for simple quick one-off sites where development speed is a critical factor, but it
	 * may serve much more robust needs as it develops...
	 *
	 * Sample XML
	 *
	 * <res>
	 *  <roots>
	 *	 <!-- determines mapping from root, based on local or deploy situations -->
	 *	 <entry key="xml">xml/</entry>
	 *	 <entry key="swf">swf/</entry>
	 *	 <entry key="image">images/</entry>
	 *  </roots>
	 *	<xml testPath="../xml/" deployPath="xml/">
	 *	   <entry key="populate">populate.xml</entry>
	 *	   <entry key="quiz">quiz.xml</entry>
	 *	</xml>
	 *	<vo>
	 *	  <entry key="settings" parseType="sz.examples.config.SettingsVO">
	 *		  <root id="THX-1138" title="A GREAT MOVIE" address=":123:456:789"/>
	 *	  </entry>
	 *	</vo>
	 *	<vector>
	 *	   <!-- STEERING CONTROL KEYFRAME EVENT TRIGGERS -->
	 *	   <entry key="s1_steer_framescript_keyframes"	parseType="int"	 >:2:35:65</entry>
	 *	   <entry key="s1_steer_framescript_amounts"	  parseType="number"  >:-2:1:-1</entry>
	 *	   <entry key="s1_steer_framescript_speeds"	   parseType="number"  >:1.8:1.3:1</entry>
	 *	</vector>
	 *	<boolean>
	 *	   <entry key="one">true</entry>
	 *	   <entry key="two">false</entry>
	 *	   <entry key="three">sjvhkfj</entry>
	 *	   <entry key="four">4.8</entry>
	 *	   <entry key="five">5.6</entry>
	 *	   <entry key="six">6.1</entry>
	 *	</boolean>
	 *	<int>
	 *	   <entry key="one">1</entry>
	 *	   <entry key="two">2.5</entry>
	 *	   <entry key="three">-3</entry>
	 *	   <entry key="four">-4.8</entry>
	 *	</int>
	 *	   <number dictClass="number">
	 *	   <entry key="one">2.3</entry>
	 *	   <entry key="two">1</entry>
	 *	</number>
	 *	<string>
	 *	   <entry key="one">hi bob</entry>
	 *	   <entry key="two">1</entry>
	 *	   <entry key="three">9877dfjk</entry>
	 *	</string>
	 *	<loadGroups priority="0">
	 *	   <entry key="scenes" type="swf" priorityType="sequential" loadImmediately="false">
	 *		  <item id="scene1">scene1.swf</item>
	 *		  <item id="scene2">scene2.swf</item>
	 *		  <item id="scene3">scene3.swf</item>
	 *		  <item id="scene4">scene4.swf</item>
	 *		  <item id="scene5">scene5.swf</item>
	 *		  <item id="scene6">scene6.swf</item>
	 *		  <item id="scene7">scene7.swf</item>
	 *	   </entry>
	 *	</loadGroups>
	 *	<swf_libs>
	 *	   <entry key="components">swf/LR_components.swf</entry>
	 *	</swf_libs>
	 * </res>
	 *
	 * __ EXAMPLE 1 __________________________________________________________________________________
	 *
	 * // in doc class, start the config cascade
	 *  _controller.config('xml/config.xml');
	 *
	 * // in controller
	 * public function config($xmlPath : String):void{
	 *   // set the prefix of the config.xml path depending on testing vs. deployment modes
	 *	 R.setRoots("","../");
	 *   // register parsers for the remaining XMLs
	 *	 R.registerParser("populate", Populate.parse);
	 *	 R.registerParser("quiz", QuizVO.parse);
	 *   // start the config process
	 *	 R.config(R.root + $xmlPath, null, _onConfig);
	 * }
	 *
	 * __ END OF EXAMPLE 1 __________________________________________________________________________________
	 *
	 * R will also automatically map the flash vars from the html context to the page params vo, provided that the names
	 * of the flash vars and the names of the VO properties are identical.  Just set the defaults
	 * for local testing in the vo object itself, and the defaults will remain unless the html context exists and
	 * overrides them.
	 *
	 * __ EXAMPLE 2 __________________________________________________________________________________
	 *
	 * //in whatever custom params VO class
	 *  public class PageParamsVO
	 * {
	 *	 public var testString : String = "defaultString";
	 *	 public var testBool : Boolean = true;
	 *	 public var testInt : int = 22;
	 *	 public var testNum : Number = 456.78;
	 * }
	 *
	 * // in the document class
	 * R.setContext(this, PageParamsVO);
	 *
	 * __ END OF EXAMPLE 2 __________________________________________________________________________________
	 *
	 *
	 *
	 *	   ________________________________________________________________________________
	 *
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 01.16.2011
	 *
	 */


	public class R {
		private static var _binder : Binder;
		// roots used for the prefixes of loading paths depending on state of publication; deploy, IDE testing or debug modes
		public static var root : String = "";
		public static var rootDeploy : String = "";
		public static var rootIDE : String = "";
		public static var rootDebug : String = "";
		public static var configXML : XML;
		public static var rootDisplayObject : DisplayObject;
		public static var params : Object;
		private static var _roots : Dictionary;
		private static var _vo : Dictionary;
		private static var _bool : Dictionary;
		private static var _int : Dictionary;
		private static var _uint : Dictionary;
		private static var _num : Dictionary;
		private static var _str : Dictionary;
		private static var _array : Dictionary;
		private static var _vector : Dictionary;
		private static var _path : Dictionary;
		private static var _xmlLoaders : Dictionary;
		private static var _xmlPaths : Dictionary;
		private static var _swfLibs : Dictionary;
		private static var _loadGroups : Dictionary;
		private static var _loadGroupsIndexes : Dictionary;
		private static var _imagePreloader : ImagePreloader;
		private static var _indexes : Array;
		private static var _onParseCallbacks : Vector.<Function>;
		private static var _imagePaths : Dictionary;
		private static var _notifyComplete : Boolean;
		private static var _configCall : XMLCall;
		private static var _parseHandlerIndex : Dictionary;
		private static var _rootsApplyIndex : Dictionary;
		public static const FAIL : String = "_fail";

		//  public switches
		public static var doTraceData : Boolean = true;
		private static var _onSWFLibLoadHandler : Function;

		public function R() {
			throw new IllegalOperationError("Illegal instantiation attempted on class, 'R', of static type.");
		}

		// ---  CONFIG --- //


		/**
		 * Sets the HTML loader context, and parses the params to the params VO based on matching property names.
		 * Only those property names introspected from the VO will get captured from the loaderInfo params.
		 */
		public static function setContext($root : DisplayObject, $paramsVO : Class = null) : void {
			rootDisplayObject = $root;
			var p : Object = $root.root.loaderInfo.parameters;
			if($paramsVO) {
				var vo : Object = new $paramsVO();
				AutoParse.mapVOFromStringObject(vo, p, true);
				params = vo;
			}

		}

		//TODO : finish roots such that one only need to set the roots and define to which loading categories (e.g. xml, images, video, etc) they apply
		/**
		 * Sets the roots or prefixes of the paths used for switching the root path based on state of the SWF
		 * publication; testing in the IDE, debugging or deployment
		 *
		 * @param $deploy - the deployment root.
		 * @param $testIDE - the root used when testing in the IDE, defaults to the deployment root.
		 * @param $debug - the debug root, defaults to the IDE testing root.
		 */
		public static function setRoots($deploy : String, $testIDE : String, $debug : String = "", ...$applyTo) : void {
			_rootsApplyIndex = new Dictionary();
			for each (var r : String in $applyTo) {
				_rootsApplyIndex[r] = true;
			}
			rootDeploy = $deploy;
			if($testIDE)rootIDE = $testIDE;
			else rootIDE = rootDeploy;

			if($debug) rootDebug = $debug;
			else rootDebug = rootIDE;

			root = (Capabilities.playerType == "StandAlone" || Capabilities.playerType == "External") ? rootIDE : rootDeploy;
		}

		/**
		 * Begins the setup and parsing cascade of R class by taking the path to the root config XML---which can contain
		 * a list of other XMLs to likewise automatically be loaded, and if set up properly, parsed.  This root config
		 * XML is then loaded and autoparsed into the index structure of the R class and the values accessed by the
		 * various getters via the keys or IDs assigned to them per index.
		 *
		 * @param $xmlPath  - the path to the root config XML containing the elements to be parsed automatically into
		 * the various R indexes, groups or Dictionaries.
		 * @param $notify   - the function to call when parsing is complete
		 * @param $fail	 - the handler for config failure, defaults to the _onConfigFail function in this class if
		 * nothing is passed.
		 */
		public static function config($xmlPath : String, $notify : Function = null, $fail : Function = null) : void {
			if($fail == null)$fail = _onConfigFail;
			if($notify != null)notifyOnParse($notify);

			_configCall = new XMLCall(getRoot(ParseTypes.X) + $xmlPath, parse, $fail);
		}

		private static function _onConfigFail($e : String) : void {
			_handleError('_onConfigFail', $e);
		}


		// --- GLOBAL PARSE AND NOTIFY --- //

		/**
		 * Parses the properly structured XML into the R index structure. See class-level documentation for the proper
		 * XML structure.
		 *
		 * @param $x - the XML or XMLList to be parsed, can be either XML or XMLList.
		 */
		public static function parse($x : *) : void {
			configXML = $x;
			//_construct = _parseDict($x.construct, ParseType.CONSTRUCT);
			_roots = _parseRoots($x.roots);
			_vo = _parseVOs($x.vo);
			_bool = _parseDict($x.bool, ParseTypes.BOOL);
			_int = _parseDict($x.int, ParseTypes.INT);
			_uint = _parseDict($x.uint, ParseTypes.UINT);
			_num = _parseDict($x.num, ParseTypes.NUM);
			_str = _parseDict($x.string, ParseTypes.STR);
			_path = _parseDict($x.uri, ParseTypes.URI);
			_swfLibs = _parseSWFLibs(_parseDict($x.lib, ParseTypes.STR));
			_loadGroupsIndexes = new Dictionary();
			_loadGroups = _parseLoadGroups(_parseDict($x.loadGroups, ParseTypes.STR));
			_imagePaths = _parseDict($x.images, ParseTypes.STR, ParseTypes.IMG);
			_imagePreloader = _parseImages(_parseDict($x.images, ParseTypes.STR));
			_xmlLoaders = _parseXMLs($x.xml);
			_array = _parseArrays($x.array);
			_vector = _parseVectors($x.vector);
			_indexes = [_xmlPaths, _bool,_int,_uint,_num,_str,_path,_loadGroups, _array, _vector, _vo];
			//traceVals();
			_notify();
		}

		/**
		 * Subscribes the callback to the list of callbacks to run on completion of the global parse.
		 */
		public static function notifyOnParse($callBack : Function) : void {
			if(!_onParseCallbacks)_onParseCallbacks = new Vector.<Function>();
			_onParseCallbacks.push($callBack);
			if(_notifyComplete)$callBack();
		}

		private static function _notify() : void {
			for each (var f : Function in _onParseCallbacks) {
				f();
			}
			_notifyComplete = true;
		}


		// --- SUB-PARSE HELPERS --- //

		/**
		 * Registers the parsers for any additional XMLs specified in the root or config XML. The $xmlID must match the
		 * ID set in the config XML for the XML path to be parsed.
		 *
		 * @param $xmlID	- The id of the XML to assign to the $parse function.
		 * @param $parse	- The function to parse the XML once it completes loading.
		 * @param $fail	 - The handler for the error if the XMLCall fails.
		 */
		public static function registerParser($xmlID : String, $parse : Function, $request : Function = null, $fail : Function = null) : void {
			if(!_parseHandlerIndex)_parseHandlerIndex = new Dictionary();
			if($request != null)request($xmlID, $request);
			// I would like to get the set val automated here, but as of now,
			// you must set the value at the end of the parse routine
			_parseHandlerIndex[$xmlID] = $parse;
			if($fail != null)_parseHandlerIndex[$xmlID + FAIL] = $fail;
		}

		private static function _parseXMLs($xx : XMLList) : Dictionary {
			var d : Dictionary = new Dictionary();
			var parser : Function;
			var fail : Function;
			var inline : Boolean;
			var lazy : Boolean;
			var key : String;
			var prefix : String = getRoot(ParseTypes.X);
			for each (var entry : XML in $xx..entry) {
				key = entry.@key;
				inline = entry.@inline + '' == "true";
				lazy = entry.@lazy + '' == "true";
				if(_parseHandlerIndex) {
					parser = _parseHandlerIndex[key] as Function;
					fail = _parseHandlerIndex[key + FAIL] as Function;
					if(fail == null) fail = _onXMLFail;
				}
				if(!inline && !lazy) {
					d[entry.@key + ''] = _newXMLCall(prefix + entry, parser, fail);
				}
				else if(lazy) {
					d[entry.@key + ''] = new LoadVO(prefix + entry, parser, fail);
				}
				else {
					d[entry.@key + ''] = XML(entry.children().toString());
				}
			}
			return d;
		}

		private static function _newXMLCall($path : String, $parser : Function, $fail : Function) : XMLCall {
			return new XMLCall($path, $parser, $fail);
		}

		private static function _onXMLFail($e : String) : void {
			_handleError('_onXMLFail', $e);
		}

		private static function _parseRoots($x : XMLList) : Dictionary {
			var dict : Dictionary = new Dictionary();
			var key : String;
			for each (var x : XML in $x..entry) {
				key = x.@key + '';
				dict[key] = getRoot(key) + x;
			}
			return dict;
		}

		private static function _parseVOs($x : XMLList) : Dictionary {
			var dict : Dictionary = new Dictionary();
			var rootX : XML;
			for each (var x : XML in $x..entry) {
				rootX = AutoParse.XMLListToXML(x.children());
				dict[x.@key + ''] = AutoParse.parseVOFromName(rootX, x.@parseType + '');
			}
			return dict;
		}

		private static function _parseDict($x : XMLList, $parseType : String, $rootType : String = null) : Dictionary {
			var dict : Dictionary;
			if($x..entry != undefined)dict = AutoParse.dictFromXMLL($x..entry, $parseType);
			if($rootType)_addRootsToDict(dict, $rootType);
			return dict;
		}

		private static function _addRootsToDict($dict : Dictionary, $rootType : String) : void {
			var root : String = getRoot($rootType);
			for(var key : Object in $dict) {
				$dict[key] = root + $dict[key];
			}
		}

		private static function _parseVectors($xv : XMLList) : Dictionary {
			var d : Dictionary = new Dictionary();
			var key : String;
			for each (var a : XML in $xv..entry) {
				key = a.@key;
				d[a.@key + ''] = AutoParse.vectorFromString(a, a.@parseType + '');
			}
			return d;
		}

		private static function _parseArrays($xa : XMLList) : Dictionary {
			var d : Dictionary = new Dictionary();
			var key : String;
			for each (var a : XML in $xa..entry) {
				key = a.@key;
				d[a.@key + ''] = AutoParse.arrayFromString(a, a.@parseType + '');
			}
			return d;
		}

		private static function _parseImages($d : Dictionary) : ImagePreloader {
			var l : ImagePreloader = imagePreloader;
			var path : String;
			for(var k : Object in $d) {
				path = getRoot(ParseTypes.IMG) + $d[k] + '';
				l.addImage(path);
				$d[k] = path;
			}
			return l;
		}

		private static function _parseSWFLibs($d : Dictionary) : Dictionary {
			var path : String;
			var l : LibraryLoader = LibraryLoader.instance;
			l.addEventListener(Event.COMPLETE, _onSWFLibLoad);
			for(var k : Object in $d) {
				path = getRoot(ParseTypes.SWF) + $d[k] + '';
				l.loadLibrary(path, ApplicationDomain.currentDomain);
			}
			return $d;
		}

		private static function _onSWFLibLoad(event : Event) : void {
			if(_onSWFLibLoadHandler != null)_onSWFLibLoadHandler();
		}

		private static function _parseLoadGroups($d : Dictionary) : Dictionary {
			var d : Dictionary = new Dictionary();
			for(var k : Object in $d) {
				d[k] = _parseLoadGroupSingle(new XML($d[k]), k + '');
			}
			return d;
		}

		private static function _parseLoadGroupSingle($lgx : XML, $key : String) : LoadGroup {
			trace('' + '$lgx.@type = ' + $lgx.@type);
			var lgIndexes : Dictionary = new Dictionary();
			var prefix : String = getRoot($lgx.@type);
			var priority : int = -1;
			if($lgx.@priority != undefined)priority = parseInt($lgx.@priority);
			var lg : LoadGroup = new LoadGroup(priority);

			var i : int = 0;
			var p : int = -1;
			var path : String;
			for each(var li : XML in $lgx..item) {
				if(li.@priority != undefined) {
					p = parseInt(li.@priority + '');
				}
				else {
					p = i;
				}
				path = prefix + li;
				lg.add(path, p, li.@type);
				lgIndexes[li.@id + ''] = i;
				i++;
			}
			if($lgx.@loadImmediately + '' != "false")lg.load();
			_loadGroupsIndexes[$key] = lgIndexes;
			return lg;
		}


		// --- DATA GETTERS --- //

		public static function getXML($key : String) : XML {
			var d : * = _xmlLoaders[$key];
			if(_xmlLoaders && d != null) {
				if(d is XMLCall) return XMLCall(d).xml;
				if(d is LoadVO) {
					load(ParseTypes.X, $key);
					return null;
				}
				else return d as XML;
			}
			load(ParseTypes.X, $key);
			return null;
		}

		public static function getVO($key : String) : * {
			if(_vo && _vo[$key] != null)return _vo[$key];
			_reportKeyError($key, ParseTypes.VALUE_OBJECT);
			return null;
		}

		public static function getBool($key : String) : Boolean {
			if(_bool && _bool[$key] != null)return _bool[$key];
			_reportKeyError($key, ParseTypes.BOOL);
			return false;
		}

		public static function getNum($key : String) : Number {
			if(_num && _num[$key] != null)return _num[$key];
			_reportKeyError($key, ParseTypes.NUM);
			return NaN;
		}

		public static function getInt($key : String) : int {
			if(_int && _int[$key] != null)return _int[$key];
			_reportKeyError($key, ParseTypes.INT);
			return undefined;
		}

		public static function getVector($key : String) : * {
			if(_vector && _vector[$key] != null)return _vector[$key];
			_reportKeyError($key, ParseTypes.VEC);
			return null;
		}

		public static function getArray($key : String) : Array {
			if(_array && _array[$key] != null)return _array[$key];
			_reportKeyError($key, ParseTypes.ARR);
			return null;
		}

		public static function getUint($key : String) : uint {
			if(_uint && _uint[$key] != null)return _uint[$key];
			_reportKeyError($key, ParseTypes.UINT);
			return undefined;
		}

		public static function getString($key : String) : String {
			if(_str && _str[$key] != null)return _str[$key];
			_reportKeyError($key, ParseTypes.STR);
			return null;
		}

		public static function getLoadGroup($key : String) : LoadGroup {
			if(_loadGroups && _loadGroups[$key] != null)return _loadGroups[$key];
			_reportKeyError($key, ParseTypes.LOAD_GROUP);
			return null;
		}

		public static function getLoadGroupItem($groupID : String, $itemID : String) : LoadItem {
			var lg : LoadGroup = getLoadGroup($groupID);
			if(_loadGroupsIndexes && _loadGroupsIndexes[$itemID]) {
				var li : LoadItem = lg.entries[_loadGroupsIndexes[$itemID]];
				if(li)return li;
			}
			_reportKeyError($itemID, ParseTypes.LOAD_GROUP_ITEM);
			return null;
		}

		public static function getImage($key : String) : Loader {
			if(_imagePreloader && _imagePaths[$key] != null)return _imagePreloader.getImage(_imagePaths[$key] + '');
			_reportKeyError($key, ParseTypes.IMG);
			return null;
		}

		public static function get imagePreloader() : ImagePreloader {
			if(!_imagePreloader)_imagePreloader = new ImagePreloader();
			return _imagePreloader;
		}

		public static function get imagePaths() : Array {
			if(!_imagePaths)return null;
			var a : Array = [];
			for each (var path : String in _imagePaths) {
				a.push(path);
			}
			return a;
		}

		// --- BINDER HELPER METHODS --- //

		public static function subscribe($prop : *, $callback : Function, $pSendAsEvent : Boolean = false) : void {
			binder.subscribe($prop, $callback, $pSendAsEvent);
		}

		public static function request($prop : *, $callback : Function, $pSendAsEvent : Boolean = false) : void {
			binder.request($prop, $callback, $pSendAsEvent);
		}


		public static function setVal($prop : *, $val : *, $pNotify : Boolean = true) : void {
			binder.setVal($prop, $val, $pNotify);
		}

		// --- REPORTING & TRACING --- //

		private static function _reportKeyError($key : String, $indexType : String) : void {
			FBtrace('R :: ' + $key + ' is not found in the ' + $indexType + ' index');
		}

		private static function _handleError($methodName : String, $e : String = "ERROR") : void {
			trace('________________________________________________________________________________\r' +
						  'R : ERROR :: METHOD' + $methodName + ' :: ' + $e + '' +
						  '________________________________________________________________________________');
		}

		public static function traceVals() : void {
			trace('________________________________________________________________________________\r' +
						  'R : TRACING VALS');
			for each (var i : Dictionary in _indexes) {
				trace('index = ' + i);
				for(var key : Object in i) {
					trace('   ' + key + ' = ' + i[key]);
				}
			}
			trace("________________________________________________________________________________")
		}


		// --- MISC --- //

		public static function get binder() : Binder {
			if(!_binder)_binder = new Binder();
			return _binder;
		}

		public static function getRoot($type : String) : String {
			var r : String = '';
			if(_rootsApplyIndex && _rootsApplyIndex[$type]) {
				if(_roots && _roots[$type])r = _roots[$type];
				else r = root;
			}
			return r;
		}

		public static function load($type : String, $id : String) : void {
			switch($type) {
				case ParseTypes.X:
					if(_xmlLoaders[$id])var pxvo : LoadVO = _xmlLoaders[$id];
					if(pxvo) {
						_xmlLoaders[$id] = _newXMLCall(pxvo.path, pxvo.result, pxvo.fail);
						return;
					}
					_handleError("load", "ERROR :: No load data found for id : " + $id);
					break;
				default:
					_handleError("load", "ERROR :: $type '" + $type + "' not found, use R constants, e.g. X")
			}
		}

		public static function set onSWFLibLoadHandler(value : Function) : void {
			_onSWFLibLoadHandler = value;
		}

		public static function register($classes : Array) : void {
			var c : Class;
			for each (c in $classes) {
				if(c is Class)Introspect.registerClasses(c);
			}
		}

		public static function getInstance($class : String) : * {
			return LibraryLoader.instance.getClassInstance($class);
		}
	}
}
