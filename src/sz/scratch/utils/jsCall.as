package sz.scratch.utils {
	import com.core.utils.FBtrace;

	import flash.external.ExternalInterface;

	public function jsCall($array : Array) {
		if(ExternalInterface.available) {
			FBtrace('calling JS :: ' + $array);
			switch($array.length) {
				case 1:
					ExternalInterface.call($array[0]);
				case 2:
					ExternalInterface.call($array[0], $array[1]);
				case 3:
					ExternalInterface.call($array[0], $array[1], $array[2]);
				case 4:
					ExternalInterface.call($array[0], $array[1], $array[2], $array[3]);
				case 5:
					ExternalInterface.call($array[0], $array[1], $array[2], $array[3], $array[4]);
				case 6:
					ExternalInterface.call($array[0], $array[1], $array[2], $array[3], $array[4], $array[5]);
				case 7:
					ExternalInterface.call($array[0], $array[1], $array[2], $array[3], $array[4], $array[5], $array[6]);
				case 8:
					ExternalInterface.call($array[0], $array[1], $array[2], $array[3], $array[4], $array[5], $array[6], $array[7]);
				case 9:
					ExternalInterface.call($array[0], $array[1], $array[2], $array[3], $array[4], $array[5], $array[6], $array[7], $array[8]);
				case 10:
					ExternalInterface.call($array[0], $array[1], $array[2], $array[3], $array[4], $array[5], $array[6], $array[7], $array[8], $array[9]);
			}
		}
		else {
			FBtrace("ERROR :: jsCall method :: ExternalInterface unavailable for call : " + $array);
		}
	}
}