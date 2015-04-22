/**
 * User: jmorrison
 * Date: 3/6/11
 * Time: 8:25 AM
 */
package sz.scratch.load.progress {
	public interface ILoaderProgressObject {
		function get percent() : Number;

		function getObject() : *;
		function getContent() : *;

		function addEventListener(type:String,listener:Function,useCapture:Boolean = false,priority:int = 0,useWeakReference:Boolean = false):void;
	}
}
