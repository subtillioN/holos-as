package sz.holos.func {
	/**
	 * From Bruce Eckel
	 * http://www.artima.com/weblogs/viewpost.jsp?thread=230610
	 *
	 * zip() returns a list of tuples (read-only sequences) where each tuple contains the nth element of each of the argument sequences. We don't have tuples in ActionScript, so our zip() will just create Arrays.

	 If the input arrays are of different sizes, the result is the length of the smallest input array:

	 Note that the complexity of the smallest initialization expression requires a semicolon.

	 Here's a test that demonstrates the behavior of zip():

	 <?xml version="1.0" encoding="utf-8"?>
	 <mx:Application name="ZipTest" xmlns:mx="http://www.adobe.com/2006/mxml">
	 <mx:creationComplete>
	 include "../../Mindview/includes/show.as"
	 import com.mindviewinc.functional.zip
	 var a:Array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
	 a.setName("a")
	 var b:Array = "abcdefghijkl".split('')
	 b.setName("b")
	 var c:Array = "qrstuvwxyz".split('')
	 c.setName("c")
	 a.show()
	 b.show()
	 c.show()
	 zip().show()
	 zip(a).show()
	 zip(a,b).show()
	 zip(a,b,c).show()
	 </mx:creationComplete>
	 </mx:Application>
	 And the output:

	 a: [1,2,3,4,5,6,7,8,9,10,11,12]
	 b: [a,b,c,d,e,f,g,h,i,j,k,l]
	 c: [q,r,s,t,u,v,w,x,y,z]
	 []
	 [[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]]
	 [[1,a],[2,b],[3,c],[4,d],[5,e],[6,f],[7,g],[8,h],[9,i],[10,j],[11,k],[12,l]]
	 [[1,a,q],[2,b,r],[3,c,s],[4,d,t],[5,e,u],[6,f,v],[7,g,w],[8,h,x],[9,i,y],[10,j,z]]
	 * @param arrays
	 * @return
	 */
	public function zip(...arrays) : Array {

		// Find the shortest array:
		var smallest : int = arrays.map(
				function(e : *, i : int, a : Array) : int {
					return e.length;
				}).sort()[0];
		var result : Array = new Array(smallest);
		for(var i : int = 0; i < result.length; i++) {
			var tuple : Array = [];
			for(var a : * in arrays) {
				tuple.push(arrays[a][i]);
			}
			result[i] = tuple;
		}
		return result;
	}
}