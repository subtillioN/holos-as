package sz.examples.resource_control {
	import sz.holos.reflect.Introspect;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/24/11
	 *
	 */
	public class InstantiatorTestClass {
		public var num : Number;
		public var id : String;

		public function InstantiatorTestClass($argS: String,$argN: Number) {
			id = $argS;
			num = $argN;
			Introspect.traceObject(this, true, "\r\r\r");
		}
	}
}