/**
 * returns a new instance with up to 10 args...unfortunately since apply() cannot be applied to constructor functions, this seems to be the common verbose way to do this.
 */

package sz.holos.factory.construct {
	/**
	 *
	 * adapted from uk.co.bigroom.utils package by Richard Lord.
	 *
	 * This function is used to construct an object from the class and an array of parameters.
	 *
	 * @param $t The class to construct.
	 * @param params An array of up to ten parameters to pass to the constructor.
	 */
	public function construct($t : Class, $a : Array) : * {
		if(!$a)$a = [];
		switch($a.length) {
			case 0:
				return new $t();
			case 1:
				return new $t($a[0]);
			case 2:
				return new $t($a[0], $a[1]);
			case 3:
				return new $t($a[0], $a[1], $a[2]);
			case 4:
				return new $t($a[0], $a[1], $a[2], $a[3]);
			case 5:
				return new $t($a[0], $a[1], $a[2], $a[3], $a[4]);
			case 6:
				return new $t($a[0], $a[1], $a[2], $a[3], $a[4], $a[5]);
			case 7:
				return new $t($a[0], $a[1], $a[2], $a[3], $a[4], $a[5], $a[6]);
			case 8:
				return new $t($a[0], $a[1], $a[2], $a[3], $a[4], $a[5], $a[6], $a[7]);
			case 9:
				return new $t($a[0], $a[1], $a[2], $a[3], $a[4], $a[5], $a[6], $a[7], $a[8]);
			case 10:
				return new $t($a[0], $a[1], $a[2], $a[3], $a[4], $a[5], $a[6], $a[7], $a[8], $a[9]);
			default:
				return null;
		}
	}
}
