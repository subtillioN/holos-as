/**
 *
 */
package sz.holos.factory.construct {
	public class ConstructorVO {
		public var objectClass : *;
		public var params : Array;
		public function ConstructorVO($objectClass : Class = null, ...$params) {
			if($objectClass){
				objectClass = $objectClass;
				params = $params;
			}
		}
	}
}
