package sz.holos.config {
	import sz.holos.config.AutoParse;
	import sz.holos.reflect.Introspect;

	/**
	 * A base class for VOs used for adding recursive auto-parsing (via
	 * AutoParse) and detailed object tracing (via Introspect) functionality.  It
	 * contains the methods for tracing out the properties of its subclasses and for
	 * auto-parsing and populating their data from xml data (automatically typing and
	 * assigning property values via AutoParse, including recursively auto-parsing
	 * ValueObject subclass properties of the ValueObject, and arrays).  See the
	 * AutoParse class for details on the many benefits (besides a huge savings of
	 * time) for AutoParsing value objects.
	 *
	 * For any value object class that extends AutoParseVO, in order to change or
	 * customize the parsing from the default straight autoparsing, one simply
	 * needs to override the inherited 'parse()' method, and either use the 'include'
	 * or 'exclude' arguments on the default AutoParse.vo() method to only autoparse
	 * what's needed and then manually parse the rest within the 'parse' method.
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since Dec 24, 2009
	 *
	 */

	public class AutoParseVO {
		/**
		 * Delegates to AutoParse.vo() to parse the ValueObject subclass.  For customization of parsing in the subclass,
		 * parse should be overridden.  At that point, AutoParse.vo() can be used with either the $include or $exclude
		 * parameter options, and the excluded properties parsed by hand, or all properties can be parsed by hand.
		 *
		 * <p>Description from AutoParse.vo(), see the class-level commenting in AutoParse for more details.
		 * <p>AutoParse.vo() automatically parses the xml successfully if the attribute and node names are identical
		 * to the property names of the VO, and (for non-Array VO properties) so long as there is only a single
		 * level of node nesting.  Those non-Array property/XML matches that don't meet these criteria will
		 * simply fail to get the value from the XML.
		 *
		 * <p>If using array properties in the VO, however, one can take two main pathways corresponding to
		 * whether the array is specified at the attribute level or with deeper xml nodes.  The attribute style
		 * only allows single-dimensional arrays, whereas the node style allows multi-dimensional arrays composed
		 * either of more arrays, or of VOs.
		 *
		 * <p>The first approach, using XML attributes, allows one to use AutoParse array parsing to parse the values
		 * into the VO array property according to the simple class type specified by an extra attribute named
		 * 'elementClass', such as elementClass="number" (case insensitive).  Putting the array values in an XML
		 * attribute, one must specify the delimiter as the first character, which will get stripped out and used
		 * as such.</p>
		 *
		 * AutoParse can also handle auto-indexing of VOs in an Array. For example, if in an array of VOs you have an
		 * 'index' property that you need to increase in value with each VO down the Array, AutoParse can automatically
		 * iterate that value.  This means that each VO in the Array property of the main VO would get an 'index' value
		 * greater than the preceding VO, and starting from a value specified in the XML.
		 *
		 * @param $xml      Untyped - the XML or XMLList to be parsed.
		 * @param $exclude  Array - the array of property strings to exclude from the parsing.  Mutually exclusive with
		 *                      $include.
		 * @param $include  Array - the array of property strings to include from the parsing (all else will be excluded.
		 *                      Mutually exclusive with $exclude.
		 *
		 */
		public function parse($xml : *, $exclude : Array = null, $include : Array = null) : void {
			AutoParse.parseVO(this, $xml, $exclude, $include);
		}

		/**
		 * Registers the VO classes to be dynamically parsed from the XML via AutoParse, which ensures they are in the
		 * library when needed.
		 * @param rest
		 */
		public static function registerVOs(...rest) : void {
			for each (var classRef : Class in rest) {
				Introspect.registerObject(new classRef());
			}
		}

		/**
		 * Delegates to Introspect.objectToString for detailed tracing.
		 * @return String - Returns the results of Introspect.objectToString on 'this'
		 */
		public function toString() : String {
			return Introspect.objectToString(this, true);
		}
	}
}
