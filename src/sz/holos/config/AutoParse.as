package sz.holos.config {
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import sz.holos.type.ParseTypes;
	import sz.holos.reflect.Introspect;

	/**
	 * DESCRIPTION
	 * <p>AutoParse is a static class for automatically parsing XML
	 * into various data holders (e.g. value objects or arrays).
	 * It does this very flexibly by a correspondence between
	 * both (1) the names of the properties of the ValueObject
	 * subclass (VO herein) and (2) the names of either the
	 * first-level attributes or child nodes (of the root XML node(s)
	 * passed into the AutoParse.vo() function).
	 * <p>
	 * <p>
	 * BENEFITS
	 * <p>
	 * One benefit of this approach is that it keeps your naming convention
	 * clean between the xml nodes or attributes and their corresponding
	 * names in the VOs.  And it keeps the xml structure coherent and
	 * consistent, as well, such that once you know the system, it becomes
	 * very easy to track down the XML data source of the variables, rather
	 * than having things show up in undefined places.
	 * <p>
	 * Another benefit is that it enables a certain predictable flexibility
	 * in changes to the XML after the parser/VO correspondence has been
	 * established. This is because the parser does not care whether you use
	 * child nodes or attributes in this name-correspondence between VO and
	 * XML.  And it doesn't care if you sometimes use one, and sometimes
	 * another (say if you suddenly discover that you need a
	 * CDATA node rather than an attribute string), for data parsed into
	 * instances of the same VO. All sorts of mixtures and variations can
	 * be used across the XML nodes corresponding to the main VO class
	 * to be parsed.  So long as the naming correspondence between the VO
	 * properties and the first-level XML data exists (barring further
	 * criteria for the higher-level functionality available in AutoParse).
	 * <p>
	 * All of this makes debugging easier, and the rigour of the naming
	 * correspondence and hierarchical ordering conventions, etc.., is a
	 * small price to pay for the benefits involved of the increase in
	 * order and not needing to write any parsers, for the most common
	 * needs.
	 * <p>
	 * <p>
	 * INDEFINITE VO HIERARCHIES
	 * <p>
	 *    For VOs, it can handle an indefinite hierarchy or nested
	 * series of VOs and/or n-dimensional Arrays (Arrays, within
	 * Arrays, etc...).  For example, this could be a VO with an
	 * Array holding more VOs, or a VO with a property that is a VO,
	 * which has a property that is also a VO, ad infinitum.  Or any
	 * hierarchical mixture of the two (e.g. a VO, with an Array of
	 * VOs containing VOs as properties, with Arrays of VOs or simple
	 * types, etc.).
	 * <p>
	 * <p>
	 * AUTO-INCREMENTING INDEX VARIABLES
	 * <p>
	 *    AutoParse can also handle the auto-incrementing of an 'index'
	 * value on the VOs in an Array property of the main VO.
	 * For example, if in an Array of VOs you would like an 'index'
	 * property to increase in value with each VO down the Array,
	 * so that each successive VO has a higher value (eliminating the
	 * need to enter, and re-enter, and keep track of these values in
	 * the XML)AutoParse can automatically iterate that value.  This
	 * means that each VO in the Array property of the main VO would
	 * get an 'index' value one-greater than the preceding VO, and
	 * starting from a value specified in the XML.
	 * <p>
	 * <p>
	 * PROPERTY INJECTIONS FOR NESTED VALUE OBJECTS
	 * <p>
	 *     AutoParse can automatically inject values into your ValueObject properties as it parses them. This can be set
	 * in the xml via the Dictionary syntax (",:TestVO1:prop1:type1:value1,:TestVO2:prop2:type2:value2", also see below),
	 * or set via the VOInject() method with an Array formatted string (":TestVO1:prop1:type1:value1", also see below)
	 * sets the injections on AutoParse based on a string value.  Used internally, injections can be set in the XML at
	 * any root node passed into the AutoParse.vo method.
	 *
	 * <p>
	 * Note that the initial delimiter(s) for the two styles below are entirely arbitrary and decided
	 * by whatever character the user passes in for those initial characters.
	 *
	 * * e.g.
	 *
	 *  <VOInjections>
	 <inject>:TableCellVO:checkColor:number:0x00FF00</inject>
	 <inject>:PageVO:disclaimerY:number:20</inject>
	 </VOInjections>

	 or
	 <root VOInject=":TableCellVO:checkColor:number:0x00FF00">
	 or
	 <root VOInjections=",:TableCellVO:checkColor:number:0x00FF00,:PageVO:disclaimerY:number:20">

	 * <p>
	 * <p>
	 * CUSTOMIZATION
	 * <p>   For VOs, AutoParse can also be customized by using the
	 * $include and $exclude parameters, and/or by overriding the 'parse'
	 * method of the ValueObject superclass for those nested VOs and/or
	 * using the $include and $exclude parameters and custom parsing in
	 * that overridden 'parse' method to handle the excluded properties
	 * (see below).
	 * <p><p><p>
	 *
	 * CRITERION FOR SUCCESSFUL PARSING
	 * <p>The criterion for a successful parse into the specified VO class(s),
	 * and/or Arrays is predicated on several factors.
	 * <p><p>
	 *		 1) Each VO class must be included somewhere in the compiled code for
	 * a class reference to be retrieved from the fully qualified name in the xml.
	 * <p><p>
	 *		 2)must property name must match exactly the XML names of either
	 * a first-level child node or an attribute on the root node, depending on
	 * what you want to do with the data.
	 * <p><p>
	 *	    3) If the property on the VO corresponding to a childnode in the XML
	 * is another VO, it must subclass ValueObject and adhere to the
	 * criterion for auto-parsing VOs.
	 * <p><p>
	 *	    4) If the property on the VO---corresponding in the XML to a childnode
	 * or to an attribute---is an Array, its elements will get typed as String
	 * unless the fully qualified class name of the required data-type is
	 * specified in an 'parseType' attribute on either the root level or
	 * the first node level, for an attribute Array or for a child node Array,
	 * respectively.  This is the same for a Dictionary, except that the
	 * corresponding attribute has the name 'parseType'. For the dictionary,
	 * the keys will be Strings, and the values will be determined by the value
	 * of 'parseType'.
	 * <p><p>
	 *	    5) Attribute-level Arrays must specify the delimiter as the first
	 * character of the string, e.g. testArray=":one:true:wrong:false".
	 * And attribute-level Dictionaries must specify two delimeters, e.g.
	 * testDict=",:one:true,two:wrong,three:false", the first one to split
	 * the key/value pairs, and the second one to split the key from the
	 * value.
	 * <p><p>
	 *	    6) Child level or node-style (as opposed to attribute-style) Dictionary
	 * data (corresponding to Dictionary properties on the currently parsing
	 * VO) must include a 'key' attribute in the nodes to be parsed into the
	 * Dictionary property on the main VO.  In the example below you can see how
	 * the thumbnail nodes each have a 'key' attribute.
	 * <p>
	 * <mainNode>
	 *		 <testDictVO parseType="com.mazda.mazda5.main.vo.GalleryThumbnailVO" indexBegin="8">
	 *			<thumbnail key="diablo" x="408" y="229" filename="Thumb_01.jpg" />
	 *			<thumbnail key="bob" x="558" y="343" filename="Thumb_02.jpg" />
	 *			<thumbnail key="marlene" x="650" y="214" filename="Thumb_03.jpg" />
	 *			<thumbnail key="peggy" x="401" y="407" filename="Thumb_04.jpg" />
	 *			<thumbnail key="bigbird" x="297" y="347" filename="Thumb_05.jpg" />
	 *			<thumbnail key="barney" x="793" y="319" filename="Thumb_06.jpg" />
	 *		</testDictVO>
	 * </mainNode>
	 * <p><p>
	 *	    7) For correctly iterating the 'index' properties on number-ordered VOs
	 * in either Dictionary or Array XML node-style data, an 'indexBegin' attribute
	 * must be present in the XML data (see above example).  This value specifies
	 * the begin value for the iteration sequence, and it must be coupled
	 * with an 'index' property of the Number data-type on the corresponding
	 * ValueObject subclass or VO.  So if you start with indexBegin="6", you'll
	 * get values in your VOs for 'index' such as 6,7,8...
	 * <p><p><p>
	 *
	 * CUSTOMIZING OR HYBRIDIZING YOUR PARSING
	 * <p>    AutoParse VO parsing (AutoParse.vo()) also includes arguments
	 * for including or excluding properties.  These are arrays which need
	 * to be populated with the names of the VO properties to either include
	 * or to exclude from the parsing.  But importantly, these two values
	 * are mutually exclusive.  If you include properties for parsing,
	 * only those properties will get parsed.  And if you exclude properties,
	 * all properties but the excluded will get parsed.  If you pass values
	 * into each, it'll return an error.  Use these properties to take a
	 * hybrid approach to parsing, where necessary, using AutoParse for those
	 * properties it can handle, and hand coding the rest.  For customizing
	 * the sub-level or nested VOs, override the 'parse' method with your
	 * custom or hybrid code, and AutoParse will call your custom parsing
	 * rather than the super-class reference to AutoParse.vo() on those
	 * sub-level nested VOs.
	 * <p><p><p>
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since Jan 27, 2010
	 *
	 */

	public class AutoParse {
		private static var _excludeFromParse : Array;
		private static var _includeInParse : Array;
		private static var _errors : Boolean = true;
		private static const AUTOPARSE_EXCEPTION : String = "[AutoParse] ERROR: ";
		private static var _injectionIndex : Dictionary;

		public function AutoParse() {
			throw new IllegalOperationError("Illegal instantiation attempted on class, 'AutoParse', of static type.");
		}


		//--------------------------------------------------------------------------
		//
		//   VO PARSE METHODS
		//
		//--------------------------------------------------------------------------

		/**
		 *
		 * @param $vo
		 * @param $o
		 * @param $keepDefaults
		 */
		public static function mapVOFromStringObject($vo : Object, $o : Object, $keepDefaults : Boolean = true) : void {
			// get className
			var className : String = Introspect.registerObject($vo);
			// get props and types
			var props : Array = Introspect.getPropsFromName(className);
			var types : Dictionary = Introspect.getPropTypesFromClassName(className);
			var types_full : Dictionary = Introspect.getPropTypesFromClassName(className, true);

			// reference to individual prop types in the types array
			var type : String;
			var typeFull : String;
			var newVal : *;
			var origVal : *;

			// iterate through the props and types to find and set the values from the xml in the vo.
			for each (var prop : String in props) {
				// check to see if the prop is matched to an attribute or a child node
				type = types[prop];
				typeFull = types_full[prop];
				newVal = $o[prop];
				origVal = $vo[prop];
				if($keepDefaults && !newVal) newVal = origVal;
				setVOPropSimpleFromString($vo, prop, type, newVal);
			}
		}


		public static function cloneProps($donor : *, $clones : Array) : void {
			Introspect.registerObject($donor);
			var props : Array = Introspect.getPropsFromName(getQualifiedClassName($donor));
			for each (var o : Object in $clones) {
				for each (var prop : String in props) {
					try {
						o[prop] = $donor[prop];
					} catch(error : Error) {
						trace("clone error: " + o + ' for ' + prop);
					} finally {
					}
				}
			}
		}

		/**
		 * See class-level comments for more details...
		 * <p>Automatically parses the xml successfully if the attribute and node names are identical
		 * to the property names of the VO, and (for non-Array VO properties) so long as there is only a single
		 * level of node nesting.  Those non-Array property/XML matches that don't meet these criteria will
		 * simply fail to get the value from the XML.
		 *
		 * <p>If using array properties in the VO, however, one can take two main pathways corresponding to
		 * whether the array is specified at the attribute level or with deeper xml nodes.  The attribute style
		 * only allows single-dimensional arrays, where as the node style allows multi-dimensional arrays composed
		 * either of more arrays, or of VOs.
		 *
		 * <p>The first approach, using XML attributes, allows one to use AutoParse array parsing to parse the values
		 * into the VO array property according to the simple class type specified by an extra attribute named
		 * 'parseType', such as parseType=ParseType.NUM (case insensitive).  Putting the array values in an XML
		 * attribute, one must specify the delimiter as the first character, which will get stripped out and used
		 * as such.
		 *
		 * <p>AutoParse can also handle auto-indexing of VOs in an Array. For example, if in an array of VOs you have an
		 * 'index' property that you need to increase in value with each VO down the Array, AutoParse can automatically
		 * iterate that value.  This means that each VO in the Array property of the main VO would get an 'index' value
		 * greater than the preceding VO, and starting from a value specified in the XML.
		 *
		 * @param $vo       Object - the value object to be populated with the parsed XML or XMLList as the $xml parameter
		 * @param $xml      Untyped - the XML or XMLList to be parsed.
		 * @param $exclude  Array - the array of property strings to exclude from the parsing.  Mutually exclusive with
		 *                      $include.
		 * @param $include  Array - the array of property strings to include from the parsing (all else will be excluded.
		 *                      Mutually exclusive with $exclude.
		 *
		 */
		public static function parseVO($vo : Object, $xml : *, $exclude : Array = null, $include : Array = null) : void {
			var x : XML;
			if($xml is XMLList) {
				x = AutoParse.XMLListToXML($xml);
			}
			else {
				if($xml is XML) {
					x = $xml as XML;
				}
			}

			x.ignoreComments = true;
			x.ignoreWhitespace = true;
			_excludeFromParse = $exclude;
			_includeInParse = $include;

			if(_excludeFromParse && _includeInParse) {
				_error(" : vo() : ARGUMENT CONFLICT : arguments $exclude and $include cannot be used simultaneously.", false);
				return;
			}
			// get className
			var className : String = Introspect.registerObject($vo);
			// get props and types
			var props : Array;

			if(!_includeInParse) {
				props = Introspect.getPropsFromName(className);
			}
			else {
				props = _includeInParse;
			}

			if(_excludeFromParse) {
				var includedProps : Array = new Array();
				var included : Boolean = true;
				for each (var p : String in props) {
					for each (var excludedProp : String in _excludeFromParse) {
						if(excludedProp == p)included = false;
					}
					if(included) includedProps.push(p);
					included = true;
				}
				props = includedProps;
			}

			var types : Dictionary = Introspect.getPropTypesFromClassName(className);
			_registerVOInjections(x, types);
			var types_full : Dictionary = Introspect.getPropTypesFromClassName(className, true);

			// reference to individual prop types in the types array
			var type : String;
			var typeFull : String;

			// iterate through the props and types to find and set the values from the xml in the vo.
			var i : int = 0;
			for each (var prop : String in props) {
				// check to see if the prop is matched to an attribute or a child node
				type = types[prop];
				typeFull = types_full[prop];
				var attribute : Boolean = x.attribute(prop) != undefined;
				var child : Boolean = x.child(prop) != undefined;
				var parseType : String = ParseTypes.STR;
				if(type.substr(0, 8) == "Vector.<") {
					parseType = type.substr(8, type.length - 9);
					type = ParseTypes.VEC;
				}
				var j : Number = NaN;
				// if the attempt to set a simple type fails, then check the array and dictionary options
				if(!setVOPropSimpleFromXML($vo, x, prop, type, attribute, child) && (attribute || child)) {
					switch(type.toLowerCase()) {
						case ParseTypes.ARR:
							// check to see if the parseType (the fully qualified classname of
							// the array elements) is specified in an attribute.
							if(x.@parseType != undefined) parseType = x.@parseType;
							if(attribute) {
								$vo[prop] = arrayFromString(x.attribute(prop), parseType);
							}
							else if(child) {
								// handle auto-iterating/indexing functions
								if(x.child(prop).@indexBegin) j = parseInt(x.child(prop).@indexBegin);
								if(x.child(prop).@parseType) parseType = x.child(prop).@parseType;
								// grab the array from arrayFromXML()
								$vo[prop] = arrayFromXMLL(XMLList(x.child(prop)).children(), parseType, j);
							}
							break;
						case ParseTypes.VEC:
							if(x.@parseType != undefined) parseType = x.@parseType;
							if(attribute) {
								$vo[prop] = vectorFromString(x.attribute(prop), parseType);
							}
							else if(child) {
								// handle auto-iterating/indexing functions
								if(x.child(prop).@indexBegin) j = parseInt(x.child(prop).@indexBegin);
								if(x.child(prop).@parseType) parseType = x.child(prop).@parseType;
								// grab the array from arrayFromXML()
								$vo[prop] = arrayFromXMLL(XMLList(x.child(prop)).children(), parseType, j);
							}
							break;
						case ParseTypes.DIC:
							if(x.@parseType) parseType = x.@parseType;
							if(attribute) {
								$vo[prop] = dictFromString(x.attribute(prop), parseType);
							}
							else {
								if(child) {
									var k : Number = NaN;
									if(x.child(prop).@indexBegin) k = parseInt(x.child(prop).@indexBegin);
									if(x.child(prop).@parseType) parseType = x.child(prop).@parseType;
									$vo[prop] = dictFromXMLL(XMLList(x.child(prop)).children(), parseType, k);
								}
							}
							break;
						case ParseTypes.X:
							if(child)$vo[prop] = XML(x.child(prop));
							break;
						default:
							// check to see if it is a vo and can auto-parse
							if(child) {
								try {
									var tempArray : Array = typeFull.split("::");
									className = tempArray[0] + '.' + tempArray[1];
									var ClassReference : Class = getDefinitionByName(className) as Class;
									var vo : AutoParseVO = new ClassReference() as AutoParseVO;
									var newXML : XMLList = x.child(prop);
									vo.parse(newXML);
									$vo[prop] = vo;
									if(_injectionIndex)_implement_VOInjection(className, vo);
								} catch(error : Error) {
									_error("Property '" + prop + "' of Class '" + typeFull + "' in '" + className + "'cannot be parsed.  Possibly either the VO does not extend AutoParseVO, or the xml is faulty: " + error);
								} finally {
								}
							}
					}
				}
				i++;
			}
		}

		/**
		 * Takes the XML (param 2) and sets the property ($prop) on the ValueObject (param 1), typing it based on the
		 * $type string.  It does this through the setVOPropSimple() method.  The key function internal of this method
		 * is to switch between attribute and child setting modes, but it is exposed in order to allow use for setting
		 * individual props via XML, agnostic of attribute or child node options.
		 *
		 * @param $vo           Object      - The ValueObject to set the property on
		 * @param $x            XML         - The XML from which to get the value
		 * @param $prop         String      - The name of the property on both the VO and in the XML
		 * @param $type         String      - The id of the data-type for either simple types or ValueObject sub-classes
		 * @param $attribute    Boolean     - Optional, used internally for switching between either attribute or child
		 *                                      node XML property settings (should be mutually exclusive with $child,
		 *                                      but both can be false, if neither can be found);
		 * @param $child        Boolean     - Optional, used internally for switching between either attribute or child
		 *                                      node XML property settings (should be mutually exclusive with $attribute,
		 *                                      but both can be false, if neither can be found);
		 * @return              Boolean     - Returns true if the property was found and set, and false if not
		 */
		public static function setVOPropSimpleFromXML($vo : Object, $x : XML, $prop : String, $type : String, $attribute : Boolean = false, $child : Boolean = false) : Boolean {
			// if both are false, then this is being set externally, so grab the values from the XML
			if(!$attribute && !$child) {
				$attribute = $x.attribute($prop) != undefined;
				$child = $x.child($prop) != undefined;
			}
			var didSet : Boolean = false;
			if($attribute) {
				didSet = setVOPropSimpleFromString($vo, $prop, $type, '' + $x.attribute($prop));
			}
			else {
				if($child) didSet = setVOPropSimpleFromString($vo, $prop, $type, '' + $x.child($prop));
			}
			return didSet;
		}

		/**
		 * Sets and data-types the property to the ValueObject from the input string.
		 *
		 * @param $vo       Object  - The ValueObject to set the property on
		 * @param $prop     String  - The name of the property on both the VO and in the XML
		 * @param $type     String  - The id of the data-type for either simple types or ValueObject sub-classes
		 * @param $value    String  - The value to be set and typed on the ValueObject
		 * @return          Boolean - Returns true if the property was found and set, and false if not
		 */
		public static function setVOPropSimpleFromString($vo : Object, $prop : String, $type : String, $value : String) : Boolean {
			var didSet : Boolean = false;
			switch($type.toLowerCase()) {
				case ParseTypes.STR:
					$vo[$prop] = $value;
					didSet = true;
					break;
				case ParseTypes.BOOL:
					$vo[$prop] = bool($value);
					didSet = true;
					break;
				case ParseTypes.NUM:
					$vo[$prop] = parseNumber($value);
					didSet = true;
					break;
				case ParseTypes.INT:
					$vo[$prop] = parseInt($value);
					didSet = true;
					break;
				case ParseTypes.UINT:
					$vo[$prop] = parseInt($value);
					didSet = true;
					break;
			}
			return didSet;
		}// setVOPropSimpleFromString()


		/**
		 * Takes the XML node and VO class name from an array list and instantiates the new ValueObject subclass and
		 * parses it.
		 *
		 * @param $xNode            XML         - The XML to parse into the ValueObject
		 * @param $parseType     String      - The fully qualified class name of the ValueObject specified in the
		 *                                          array XML
		 * @param $indexBegin       Number      - The beginning number for the index incrementing functionality for parsing arrays of VOs
		 * @return                  sz.holos.config.AutoParseVO - Returns the ValueObject populated with the parsed data
		 */
		public static function parseVOFromName($xNode : XML, $parseType : String, $indexBegin : Number = NaN) : AutoParseVO {
			var ClassReference : Class = getDefinitionByName($parseType) as Class;
			var vo : AutoParseVO = (new ClassReference() as AutoParseVO);
			// check for injections, and inject in true
			if(_injectionIndex)_implement_VOInjection($parseType, vo);
			// parse vo, overrides injections
			vo.parse($xNode);
			if($indexBegin > -1) {
				try {
					vo[ParseTypes.INDEX] = $indexBegin;
				} catch(error : Error) {
					_error("No property 'index' exists on " + $parseType + ": " + error);
				} finally {
				}
			}
			return vo;
		} // _parseNestedVO()

		// --- END OF VO PARSE METHODS --- //


		//--------------------------------------------------------------------------
		//
		//  DICTIONARY PARSING METHODS
		//
		//--------------------------------------------------------------------------

		/**
		 * Takes a String of a specific format and returns a formatted dictionary with strings as keys.  The first
		 * character of the string is the delimiter for separating the key:value pairs, and the second character is the
		 * delimiter between the key and the value, e.g. ",:key1:value1,key2:value2". The values will be typed according
		 * to the $parseType parameter.
		 *
		 * @param $inputString  String - the full string to be parsed, e.g. ",:key1:value1,key2:value2"
		 * @param $parseType    String - the simple type by which the string value will be typed, e.g int, Number, etc.
		 * @return Dictionary - formatted Dictionary
		 */
		public static function dictFromString($inputString : String, $parseType : String = "") : Dictionary {
			if($parseType == "")$parseType = ParseTypes.STR;
			var dict : Dictionary = new Dictionary();
			// split the array from the first character as delimiter 1, into string pairs.
			var pairs : Array = $inputString.split($inputString.charAt());
			pairs.shift();
			var i : int = 0;
			var delimiter2 : String;
			var pair : Array;
			for each (var stringPair : String in pairs) {
				if(i == 0) delimiter2 = stringPair.charAt();
				pair = stringPair.split(delimiter2);
				if(i == 0) pair.shift();
				formatDictElement(dict, pair, $parseType);
				i++;
			}
			return dict;
		}

		/**
		 *  Takes an XMLList and parses each node into key/value pairs according to the 'key' attribute as key.  If the
		 * $parseType is a simple type, such as int, or number, it will type the node value as that class, or if the
		 * $parseType value is the name of a fully qualified ValueObject subclass, then it will autoparse the values in
		 * the node accordingly and set the key value in the returned Dictionary as a populated ValueObject of the
		 * specified subclass.
		 *
		 * @param $inputXMLL    XMLList - the list of nodes to be parsed
		 * @param $parseType    String - the name of the type to be cast (simple) or parsed if a ValueObject subclass and
		 *                          fully-qualified
		 * @param $indexBegin   Number - if the $parseType is a ValueObject subclass and possesses an "index" int property,
		 *                          this is the number at which indexing of the indexes will begin
		 * @return              Dictionary - Returns the formatted dictionary object
		 */
		public static function dictFromXMLL($inputXMLL : XMLList, $parseType : String = "", $indexBegin : Number = NaN) : Dictionary {
			var parseTypeKey : String = $parseType.toLowerCase();
			var dict : Dictionary = new Dictionary();
			if(parseTypeKey == '')parseTypeKey = ParseTypes.STR;
			if(parseTypeKey == ParseTypes.STR || parseTypeKey == ParseTypes.INT || parseTypeKey == ParseTypes.UINT || parseTypeKey == ParseTypes.NUM || parseTypeKey == ParseTypes.BOOL) {
				var pair : Array = new Array();
				for each (var x : XML in $inputXMLL) {
					pair = ['' + x.@key, '' + x];
					formatDictElement(dict, pair, $parseType);
				}
			}
			else {
				if(parseTypeKey == ParseTypes.ARR) {
					parseTypeKey = ParseTypes.STR;
					for each (var aNode : XML in $inputXMLL
							) {
						if(aNode.@parseType) parseTypeKey = aNode.@parseType;
						dict.push(arrayFromXMLL(aNode.children(), $parseType));
					}
				}
				else if(parseTypeKey == ParseTypes.VEC) {
					parseTypeKey = ParseTypes.STR;
					for each (var vNode : XML in $inputXMLL
							) {
						if(vNode.@parseType) parseTypeKey = vNode.@parseType;
						dict.push(vectorFromXMLL(vNode.children(), $parseType));
					}
				}
				else {
					try {
						var ClassReference : Class = getDefinitionByName($parseType)
								as
								Class;
						for each (var xNode : XML in $inputXMLL
								) {
							try {
								var vo : AutoParseVO = (new ClassReference()
										as
										AutoParseVO
										)
										;
								vo.parse(xNode);
								if($indexBegin > -1) {
									try {
										vo[ParseTypes.INDEX] = $indexBegin;
										$indexBegin++;
									} catch(error : Error
											) {
										_error("No property 'index' exists on " + $parseType + ": " + error);
									}
									finally {
									}
								}
								dict[xNode.@key + ''] = vo;
							} catch(error : Error
									) {
								_error(" Class '" + $parseType + "' is not a VO, or does not possess an autoParse method: " + error);
							}
							finally {
							}
						}
					} catch(error : Error
							) {
						_error(" No class '" + $parseType + "' exists: " + error);
					}
					finally {
					}
				}
			}
			return dict;
		} // dictFromXMLL()

		// --- END OF DICTIONARY PARSING METHODS --- //


		//--------------------------------------------------------------------------
		//
		//  VECTOR PARSE METHODS
		//
		//--------------------------------------------------------------------------


		/**
		 * Takes a String of a specific format and returns a formatted Array with values typed to the simple type
		 * specified by the $parseType.  The first character of the string is the delimiter for separating the
		 * elements, e.g. ":value1:value2:value3". The values will be typed according to the simple $parseType
		 * parameter.
		 *
		 * @param $inputString  String - the full string to be parsed, e.g. ":value1:value2:value3", the first character of which is the delimiter
		 * @param $parseType    String - the simple type by which the string value will be typed, e.g int, Number, etc.
		 * @return Array - Array of typed values
		 */
		public static function vectorFromString($inputString : String, $parseType : String = "") : * {
			if($parseType == "")$parseType = ParseTypes.STR;
			// split the array from the first character as delimiter.
			var vals : Array = $inputString.split($inputString.charAt());
			vals.shift();

			vals = dataTypeArrayStrings(vals, $parseType);
			return vectorFromArray($parseType, vals);
		}

		public static function vectorFromArray($parseType : String, vals : Array) : * {
			var v : * = _newVector($parseType);
			for each (var val : * in vals) { v.push(val) }
			return v;
		}

		private static function _newVector($parseType : String) : * {
			var v : *;
			switch($parseType.toLowerCase()) {
				case ParseTypes.INT:
					v = new Vector.<int>;
					break;
				case ParseTypes.UINT:
					v = new Vector.<uint>;
					break;
				case ParseTypes.NUM:
					v = new Vector.<Number>;
					break;
				case ParseTypes.STR:
					v = new Vector.<String>;
					break;
				case ParseTypes.BOOL:
					v = new Vector.<Boolean>;
					break;
				default:
					_error("VECTOR PARSE TYPE '" + $parseType + "' IS NOT SUPPORTED.");
			}
			return v;
		}

		/**
		 * Takes an XMLList and returns an Vector of parsed and typed elements.  The possible types (specified by the
		 * $parseType parameter) include either simple types or ValueObject subclasses (specified by the
		 * fully-qualified name).
		 *
		 * @param $inputXMLL        XMLList - the list of XML nodes to be parsed (if ValueObject subclasses) or typed
		 *                              into the values of the array
		 * @param $parseType     String - the class to type (simple types) or parse to (if ValueObject subclass and
		 *                              name is fully qualified)
		 * @param $indexBegin       Number - Sets the value at which the indexing will begin, for use when the
		 *                              $parseType is a fully-qualified ValueObject subclass, and possesses an
		 *                              'index' int property.
		 * @return                  Array - the populated array containing either simple typed values, or ValueObject
		 *                              subclasses
		 */
		public static function vectorFromXMLL($inputXMLL : XMLList, $parseType : String = "") : Array {
			if($parseType == "")$parseType = ParseTypes.STR;
			var v : * = vectorFromArray($parseType, arrayFromXMLL($inputXMLL, $parseType));
			if(!v) {
				_error("CANNOT PARSE VECTOR FROM XML.");
				return null;
			}
			return v;
		} // arrayFromXMLL


		// --- END OF VECTOR PARSE METHODS --- //

		//--------------------------------------------------------------------------
		//
		//  ARRAY PARSE METHODS
		//
		//--------------------------------------------------------------------------


		/**
		 * Takes a String of a specific format and returns a formatted Array with values typed to the simple type
		 * specified by the $parseType.  The first character of the string is the delimiter for separating the
		 * elements, e.g. ":value1:value2:value3". The values will be typed according to the simple $parseType
		 * parameter.
		 *
		 * @param $inputString  String - the full string to be parsed, e.g. ":value1:value2:value3", the first character of which is the delimiter
		 * @param $parseType    String - the simple type by which the string value will be typed, e.g int, Number, etc.
		 * @return Array - Array of typed values
		 */
		public static function arrayFromString($inputString : String, $parseType : String = "") : Array {
			if($parseType == "")$parseType = ParseTypes.STR;
			var a : Array = new Array();
			// split the array from the first character as delimiter.
			var strings : Array = $inputString.split($inputString.charAt());
			strings.shift();
			a = dataTypeArrayStrings(strings, $parseType);
			return a;
		}

		/**
		 * Takes an XMLList and returns an Array of parsed and typed elements.  The possible types (specified by the
		 * $parseType parameter) include either simple types or ValueObject subclasses (specified by the
		 * fully-qualified name).
		 *
		 * @param $inputXMLL        XMLList - the list of XML nodes to be parsed (if ValueObject subclasses) or typed
		 *                              into the values of the array
		 * @param $parseType     String - the class to type (simple types) or parse to (if ValueObject subclass and
		 *                              name is fully qualified)
		 * @param $indexBegin       Number - Sets the value at which the indexing will begin, for use when the
		 *                              $parseType is a fully-qualified ValueObject subclass, and possesses an
		 *                              'index' int property.
		 * @return                  Array - the populated array containing either simple typed values, or ValueObject
		 *                              subclasses
		 */
		public static function arrayFromXMLL($inputXMLL : XMLList, $parseType : String = "", $indexBegin : Number = NaN) : Array {
			var a : Array = new Array();
			var parseTypeKey : String = $parseType.toLowerCase();
			if($parseType == '') $parseType = ParseTypes.STR;
			if($parseType.toLowerCase() == ParseTypes.STR || $parseType.toLowerCase() == ParseTypes.INT || $parseType.toLowerCase() == ParseTypes.NUM || $parseType.toLowerCase() == ParseTypes.BOOL) {
				var strings : Array = _xmlToArrayRaw($inputXMLL);
				a = dataTypeArrayStrings(strings, $parseType);
			}
			else {
				if(parseTypeKey == ParseTypes.ARR) {
					parseTypeKey = ParseTypes.STR;
					for each (var aNode : XML in $inputXMLL
							) {
						if(aNode.@parseType) parseTypeKey = aNode.@parseType;
						a.push(arrayFromXMLL(aNode.children(), $parseType));
					}
				}
				if(parseTypeKey == ParseTypes.VEC) {
					parseTypeKey = ParseTypes.STR;
					for each (var vNode : XML in $inputXMLL
							) {
						if(vNode.@parseType) parseTypeKey = vNode.@parseType;
						a.push(vectorFromXMLL(vNode.children(), $parseType));
					}
				}
				else  // check for element class as VO and attempt to parse
				{
					try {

						for each (var xNode : XML in $inputXMLL
								) {
							try {
								var vo : AutoParseVO = parseVOFromName(xNode, $parseType, $indexBegin);
								$indexBegin++;
								a.push(vo);
							} catch(error : Error
									) {
								_error(" Class '" + $parseType + "' is not a VO, or does not possess an autoParse method: " + error);
								trace('            The following XML data was not parsed: ' + xNode);
							}
							finally {
							}
						}
					} catch(error : Error
							) {
						_error(" No class '" + $parseType + "' exists: " + error);
					}
					finally {
					}
					if(a.length == 0) {
						trace("     Returning xml Array elements.");
						a = _xmlToArrayRaw($inputXMLL);
					}
				}
			}
			return a;
		} // arrayFromXMLL


		/**
		 * Takes an XMLList and returns an Array with the nodes in the array.  For use with parsing arrays from an
		 * XMLList whose nodes cannot be further parsed, either because the type cannot be found, or some other error.
		 * @param $inputXMLL  XMLList - list whose nodes wil be pushed into the elements of the Array
		 * @return   Array - populated Array
		 */
		public static function _xmlToArrayRaw($inputXMLL : XMLList) : Array {
			var a : Array = new Array();
			for each (var node : XML in $inputXMLL) {
				a.push(node);
			}
			return a;
		}

		// --- END OF ARRAY PARSE METHODS --- //


		//--------------------------------------------------------------------------
		//
		//  DATA-TYPING HELPER METHODS
		//
		//--------------------------------------------------------------------------


		/**
		 * Takes an Array of Strings and returns an Array of values data-typed to the simple value of the $parseType
		 * parameter.
		 *
		 * @param $strings          Array - the Array of Strings to by typed
		 * @param $parseType     String - The class name or simple data type used for typing the the array elements
		 * @return Array
		 */
		public static function dataTypeArrayStrings($strings : Array, $parseType : String = "") : Array {
			var a : Array = new Array();
			if($parseType == '' || $parseType == null) $parseType = ParseTypes.STR;
			switch($parseType.toLowerCase()) {
				case ParseTypes.STR:
					a = $strings;
					break;
				case ParseTypes.INT:
					for each (var s : String in $strings) {
						a.push(parseInt(s));
					}
					break;
				case ParseTypes.NUM:
					for each (var n : String in $strings) {
						a.push(Number(n));
					}
					break;
				case ParseTypes.BOOL:
					for each (var b : String in $strings) {
						a.push(bool(b));
					}
					break;
				default:
					_error("For attribute-level arrays, '@parseType=" + $parseType + "' will not work.  \r     The value must be either, ParseTypes.STR, ParseType.BOOL, 'int', or ParseType.NUM. \r     Returning string elements...");
					a = $strings;
			}
			return a;
		} // dataTypeArrayStrings()

		/**
		 * Takes a Dictionary and a Array key:value pair, and sets the value of the key typed to the $parseType simple type, e.g. (lowercase) "string"
		 * @param $dict         Dictionary - The Dictionary in which to set the values
		 * @param $pair         Array - the [key,value] pair by which to set the $dict Dictionary
		 * @param $parseType String - the simple type to set the type of the value
		 * @return              Dictionary - the initial dictionary with the added key and value
		 */
		public static function formatDictElement($dict : Dictionary, $pair : Array, $parseType : String = "") : Dictionary {
			if($parseType == "")$parseType = ParseTypes.STR;
			switch($parseType.toLowerCase()) {
				case ParseTypes.STR:
					$dict[$pair[0]] = $pair[1];
					break;
				case ParseTypes.INT:
					$dict[$pair[0]] = parseInt($pair[1]);
					break;
				case ParseTypes.UINT:
					var ui : uint = Math.max(0, parseInt($pair[1]));
					$dict[$pair[0]] = ui;
					break;
				case ParseTypes.NUM:
					$dict[$pair[0]] = Number($pair[1]);
					break;
				case ParseTypes.BOOL:
					$dict[$pair[0]] = bool($pair[1]);
					break;
				default:
					_error("For attribute-level dictionaries, '@parseType='" + $parseType + " will not work.  \r     The value must be either, ParseTypes.STR, ParseType.BOOL, ParseType.INT, or ParseType.NUM. \r     Returning string elements...");
			}
			return $dict;
		} // formatDictElement()


		/**
		 * Returns a Boolean from a String based on a comparison to "true".  If $string equals "true" the return value
		 * will equal true, otherwise, false.
		 *
		 * @param $string
		 * @return  Boolean based on a comparison to "true"
		 */
		public static function bool($string : String) : Boolean {
			return $string == "true";
		}

		/**
		 * Parses a number from the String
		 * @param $s String - the number string to be parsed
		 * @return Array
		 */
		public static function parseNumber($s : String) : Number {
			if($s == "NaN") {
				return NaN;
			}
			else {
				return Number($s);
			}
		}

		// --- END OF DATA-TYPING HELPER METHODS --- //


		//--------------------------------------------------------------------------
		//
		//  VO PROPERTY INJECTION METHODS
		//


		//--------------------------------------------------------------------------

		/**
		 * sets the injections on AutoParse based on a string value.  See below for string formatting syntax.  Used
		 * internally, injections can be set in the XML at any root node passed into the AutoParse.vo method.  See the
		 * following example.
		 * <p>
		 * Note that the initial delimiter(s) for the two styles are entirely arbitrary and decided
		 * by whatever character the user passes in for those initial characters.
		 * e.g.
		 *
		 * <root
		 *          VOInject=":TableCellVO:checkColor:number:0x00FF00"
		 *          VOInjections=",:TestVO1:prop1:type1:value1,:TestVO2:prop2:type2:value2"
		 * >
		 *
		 * <p>  This method is also used to clear injections, via the XML attribute-level settings with the following
		 * formats.
		 *
		 * 1: To clear all injections:
		 *          VOInject=":clear" or VOInject="clear"
		 * 2: To clear the injections on a particular VO class:
		 *          VOInject=":clear:TableGroupVO"
		 * 3: To clear the injection on a particular VO class of a specified property:
		 *          VOInject=":clear:TableGroupVO:rowColors"
		 *
		 * @param $injectString     String  - The array- or dictionary-formatted strings (see the arrayFromString and
		 *                              dictFromString methods for details) to specify the VO, its property, the
		 *                              data-type, and the value to be injected, respectively (not respectfully).
		 * @param $types            Array   - optional Dictionary of property-name/data-type value pairs for use in
		 *                              setting the type if the type is not found in the string.  Used internally,
		 *                              generally.
		 */
		public static function VOInject($injectString : String, $types : Dictionary = null, $xml : XMLList = null) : void {
			if(!_injectionIndex)_injectionIndex = new Dictionary();
			// check for a simple, global "clear" directive
			if($injectString == ParseTypes.INJECT_CLEAR) {
				clearVOInjections();
				return;
			}
			var arr : Array = arrayFromString($injectString);
			var voKey : String = arr[0];
			var propKey : String = arr[1];
			var type : String = arr[2];

			// check for a detailed "clear" directive of the string format, VOInject=":clear:TableCellVO:checkColor"
			if(voKey == ParseTypes.INJECT_CLEAR) {
				// remap vars to fit the more intuitive syntax for "clear" directives
				voKey = propKey ? propKey : "";
				propKey = type ? type : "";
				clearVOInjections(voKey, propKey);
				return;
			}
			if(arr[3]) var value : String = arr[3];
			if(arr[4]) var parseType : String = arr[4];
			var voDict : Dictionary = _injectionIndex[voKey];
			if(!voDict) voDict = new Dictionary();
			voDict[propKey] = value;

			// if we can't parse out the type, see if we can grab it from the types array (retrieved from Introspect and passed internally)
			if(!type) type = $types[propKey];

			// if not injecting a value object, register injection, else process VO injection
			if(type.toLowerCase() != ParseTypes.VALUE_OBJECT) {
				_injectionIndex[voKey + propKey] = type;
				_injectionIndex[voKey] = voDict;
				if(parseType)_injectionIndex[voKey + type] = parseType;
			}
			else // process ValueObject data
			{
				_injectionIndex[voKey + propKey] = type;
				_injectionIndex[voKey + propKey + ParseTypes.VALUE_OBJECT] = $xml;
				_injectionIndex[voKey] = voDict;
				if(parseType)_injectionIndex[voKey + type] = parseType;
			}
		}// VOInject()

		/**
		 * Searches the xml for the @VOInject attribute and registers the specified VO class to receive the specified
		 * property injection.
		 *
		 * e.g.
		 *
		 *      <VOInjections>
		 *          <inject>:TableCellVO:checkColor:number:0x00FF00</inject>
		 *          <inject>:PageVO:disclaimerY:number:20</inject>
		 *      </VOInjections>
		 * or...
		 *      <root VOInject=":TableCellVO:checkColor:number:0x00FF00">
		 * or...
		 *      <root VOInjections=",:TableCellVO:checkColor:number:0x00FF00,:PageVO:disclaimerY:number:20">
		 * <p>
		 * Note that the initial delimiter(s) for the two styles are entirely arbitrary and decided
		 * by whatever character the user passes in for those initial characters.

		 * @param $x        XML     - The XML to check and register the injections for
		 * @param $types    Array   - the Array of types used to data-type the injection
		 */
		private static function _registerVOInjections($x : XML, $types : Dictionary) : void {
			if($x.@VOInject != undefined) {
				VOInject('' + $x.@VOInject, $types);
			}
			if($x.VOInject != undefined) {
				VOInject('' + $x.VOInject.@string, $types, $x.VOInject.*);
			}
			if($x.@VOInjections != undefined) {
				VOInjectArray(arrayFromString($x.@VOInjections), $types);
			}
			if($x.VOInjections != undefined) {
				VOInjectArray(arrayFromXMLL($x.VOInjections..*), $types);
			}
		}

		/**
		 * Takes an array of injection strings of the format, ":TableCellVO:checkColor:number:0x00FF00", and passes them
		 * to the VOInject() method for injection.
		 *
		 * @param pairs     Array       - an array of strings for injection.
		 * @param $types    Dictionary  - optional, the dictionary of types used for datatyping the properties if the
		 *                                  type is not found in the string.
		 */
		public static function VOInjectArray(pairs : Array, $types : Dictionary = null) : void {
			for each (var s : String in pairs) {
				VOInject(s, $types);
			}
		}

		/**
		 * Injects the property data from the registered ValueObject into the specified ValueObject.
		 *
		 * @param $voClass     String       - the fully qualified class-name for the ValueObject to be injected with the
		 *                                      property value
		 * @param $vo          ValueObject  - the ValueObject to be injected with the property value
		 */
		private static function _implement_VOInjection($voClass : String, $vo : AutoParseVO) : void {
			var name_arr : Array = $voClass.split(".");
			var voKey : String = name_arr[name_arr.length - 1];
			var voDict : Dictionary = _injectionIndex[voKey];
			if(voDict) {
				Introspect.registerObject($vo);
				for(var prop : Object in voDict) {
					var p : String = prop.toString();
					var type : String = _injectionIndex[voKey + prop];
					var value : String = voDict[p];
					var typeIsVO : Boolean = (type.toLowerCase() == ParseTypes.VALUE_OBJECT || type.toLowerCase() == "vo");
					try {
						var parseType : String;
						if(type.toLowerCase() != ParseTypes.ARR && !typeIsVO) {
							setVOPropSimpleFromString($vo, p, type, value);
						}
						else {
							if(type.toLowerCase() == ParseTypes.ARR) {
								parseType = _injectionIndex[voKey + type];
								$vo[p] = arrayFromString(value, parseType);
							}
							else {
								if(type.toLowerCase() == ParseTypes.VALUE_OBJECT || type.toLowerCase() == "vo") {
									parseType = _injectionIndex[voKey + type];
									var xNode : XMLList = _injectionIndex[voKey + p + ParseTypes.VALUE_OBJECT]
											as
											XMLList;
									$vo[p] = parseVOFromName(XMLListToXML(xNode), parseType);
								}
							}
						}
					} catch(error : Error) {
						_error("VOInjection failed for parseType: " + $voClass + "  property: " + prop + "   and type: " + type);
					} finally {
					}
				}
			}
		} // _VOInjection

		/**
		 * Clears the injections on three different levels of detail.  If no values are passed in, it clears the whole
		 * injection index (setting it to null).  If a VO key is passed in, it will only clear the index for that VO
		 * along with all its property injections.  If a VO key and a property key are passed in, it will only clear the
		 * value of that property.
		 * <p>
		 * <p>  This method is also available via the XML attribute-level settings with the following formats.
		 *
		 * 1: To clear all injections:
		 *          VOInject=":clear" or VOInject="clear"
		 * 2: To clear the injections on a particular VO class:
		 *          VOInject=":clear:TableGroupVO"
		 * 3: To clear the injection on a particular VO class of a specified property:
		 *          VOInject=":clear:TableGroupVO:rowColors"
		 *
		 * @param $voKey    String - the key for the ValueObject to either clear all of its property injections, or if
		 *                      the second parameter is set, just the value of that property.
		 * @param $propKey  String - the key for the property of the ValueObject to clear.
		 * @return          Boolean - Returns true if the values were successfully retrieved and cleared, otherwise
		 *                      it returns false.
		 */
		public static function clearVOInjections($voKey : String = "", $propKey : String = "") : Boolean {
			// if there is no VO key, then null the _injectionIndex
			if($voKey == "") {
				_injectionIndex = null;
				return true;
			}
			// we'll need the VO dict to check the rest
			var voDict : Dictionary = _injectionIndex[$voKey];
			// check for ValueObject key with no prop key
			if($voKey != "" && $propKey == "") {
				// voDict if exists null it
				if(voDict) {
					_injectionIndex[$voKey] = null;
					return true;
				}
			}
			// check for property to clear
			if(voDict[$propKey]) {
				// clear the property
				voDict[$propKey] = null;
				return true;
			}
			return false;
		}//clearVOInjections()

		// --- END VO PROPERTY INJECTION METHODS --- //

		//--------------------------------------------------------------------------
		//
		//   MISC
		//
		//--------------------------------------------------------------------------


		/**
		 * Converts an XMLList to an XML object
		 * @param $xmlList  XMLList - the XMLList to be converted and returned as the XML object
		 * @return          XML - Returns the XMLList converted to XML
		 */
		public static function XMLListToXML($xmlList : XMLList) : XML {
			return new XML($xmlList.toXMLString());
		}


		/**
		 * Centralizes the error messaging for the class
		 * @param $error        String -  the error string
		 * @param $traceOnly    Boolean - defaults to true, which means that the error will only trace, not throw an error
		 */
		private static function _error($error : String, $traceOnly : Boolean = true) : void {
			trace("\r____________________________________________________\r"
					      + AUTOPARSE_EXCEPTION + $error
					      + "\r____________________________________________________\r\r");
			if(_errors && !$traceOnly)throw new Error(AUTOPARSE_EXCEPTION + $error);
		}

		/**
		 */
		public static function set errors($errors : Boolean) : void {
			_errors = $errors;
		}

		public static function stringInject($vo : Object, $recipientProp : String, $props : Array, $vals : Array = null) : String {
			if(!$vo.hasOwnProperty($recipientProp)) {
				_error("stringInject method: property "
						       + $recipientProp + " does not exist on Object.\r     Aborting operation...");
				return null;
			}
			var newString : String = $vo[$recipientProp];
			trace('newString = ' + newString);
			if(!$vals) {
				$vals = [];
				for each (var p : String in $props) {
					if(!$vo.hasOwnProperty(p)) {
						_error("stringInject method: property "
								       + p + " does not exist on Object.\r     Aborting operation...");
						return null;
					}
					$vals.push($vo[p]);
				}
			}
			for(var i : int = 0; i < $props.length; i++) {
				newString = newString.split("[" + $props[i] + "]").join($vals[i]);
			}
			$vo[$recipientProp] = newString;
			return newString;
		}


	}
}
