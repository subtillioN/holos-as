/**
 * Sample flash vars VO for the config process.  Set the initial values for the defaults.  If introspection on the page
 * context reveals any data, the default will be written over.
 */
package sz.examples.config {
	public class PageParamsVO {
		public var testing : Boolean = true;
		public var lang : String = "en";
		public var id : int = 3;
		// add new properties with default values, in the VO (above),
		// type them how you want them,
		// add them in the html embed with the identical names and ...
		// they're autoparsed into the 'params' property on R
	}
}
