package sz.examples.resource_control {
	import flash.display.MovieClip;

	import sz.holos.factory.Constructor;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/24/11
	 *
	 */


	[SWF(width="640", height="360", backgroundColor="#111111", frameRate="30")]
	public class app_resource_control extends MovieClip{
		public function app_resource_control() {
//			Constructor.defineType(InstantiatorTestClass,2);
//			var a : InstantiatorTestClass = Constructor.getInstance("a",InstantiatorTestClass,["a",5]);
//			var b : InstantiatorTestClass = Constructor.getInstance("b",InstantiatorTestClass,["b",8]);
//			var c : InstantiatorTestClass = Constructor.getInstance("c",InstantiatorTestClass,["c",12]);
//			var a2 : InstantiatorTestClass = Constructor.getInstance("a",InstantiatorTestClass);
//			trace('' + this + 'a==a2 = ' + (a==a2));
//			trace('' + this + 'a2.name = ' + a2.id);
//
//			var s3 : ExampleSingleton = new ExampleSingleton(); //error
//			var s1 : ExampleSingleton = ExampleSingleton.instance;
//			var s2 : ExampleSingleton = ExampleSingleton.instance;
//			trace('' + this + 's1==s2 = ' + (s1 == s2));
//
//
//			var m0 : ExampleMultiton = new ExampleMultiton(1,"bob","dobbs");   // error
			var m1 : ExampleMultiton = ExampleMultiton.getInstance("a",["a1","a2"]);
			var m2 : ExampleMultiton = ExampleMultiton.getInstance("b",["b2","b2"]);
//			var m3 : ExampleMultiton = ExampleMultiton.getInstance("c",["c1","c2"]); // error
			trace('' + this + 'm1.arg1 = ' + m1.arg1);
			trace('' + this + 'm2.arg1 = ' + m2.arg1);
			trace('' + this + 'm1==s2 = ' + (m1 == m2));
		}
	}
}