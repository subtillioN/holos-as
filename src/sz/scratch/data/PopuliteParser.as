package sz.scratch.data {
	import flash.text.StyleSheet;
	import flash.utils.Dictionary;

	import sz.scratch.vo.PopulateVO;
	import sz.scratch.vo.TextVO;

	/**
	 * PopuliteParser parses the xml for the Populite
	 * singleton instance.  It can be used on its own and then passed
	 * to Populite, or it can be accessed via composition
	 * through Populite.instance.parse([xml to be parsed]);
	 *
	 * <p>Populite is a light version of the Populate class, stripped of its
	 * dynamic font loading capabilities for use with fonts embedded in the
	 * FLA.</p>
	 *
	 *
	 * <CharReplacements>
	 <font name="Mazda">
	 <option char="a" replace="{"/>
	 <option char="A" replace="{"/>
	 </font>
	 </CharReplacements>
	 <GlobalColors>
	 <color id="blue"		color="#2DBEFF"/>
	 <color id="white"	   color="#FFFFFF"/>
	 <color id="offWhite"	color="#CDCECD"/>
	 <color id="grey"		color="#ACACAC"/>
	 <color id="greyDark"	color="#959595"/>
	 <color id="black"	   color="#000000"/>
	 </GlobalColors>
	 <TextContent>
	 <!-- COMMON -->
	 <!-- lockup -->
	 <text id="Lockup_allNew"	font="Mazda"  colorID="offWhite" size="25"  x="-58"  y="153" >THE ALL-NEW 2012</text>
	 <text id="Lockup_model"	 font="Mazda"  colorID="blue"				x="-70"  y="171" letterSpacing=".5"><![CDATA[<FONT size="52">M{ZD{</FONT><FONT size="34"> </FONT><FONT size="52">5</FONT>]]></text><!-- � = MC superscript for FR -->
	 <text id="Lockup_zoom"	  font="Mazda"  colorID="white"	size="75"  x="-53"  y="125"  alpha="0.07">ZOOM-ZOOM</text>
	 <!-- loading -->
	 <text id="Lockup_percent"  font="Mazda"  colorID="white"	 size="65"  x="-85"  y="211" /><!-- � = MC superscript for FR -->
	 <text id="Lockup_loading"  font="Mazda"  colorID="offWhite"  size="15"  x="-128" y="278" >LO{DING</text>
	 <!-- promo -->
	 <text id="Promo_title"	  font="Mazda"	colorID="white"	size="17"  width="692" x="499" y="50">AN UNEXPECTED VEHICLE FOR LIFE UNEXPECTED.</text>
	 <text id="Promo_body"	   font="Futura"   colorID="grey"	leading="0"  letterSpacing="0" size="14" x="398" y="69" width="650" align="right" thickness="200" antiAliasTypeAdvanced="true"
	 ><![CDATA[If there�s one thing you can count on in life, it�s to expect the unexpected. With its in motion styling <br/>and dynamic design, the six-passenger, 2.5L Mazda5 brings a whole new meaning <br/>to form and function. Mazda5 refuses to be categorized. Surprisingly nimble and roomy. <br/>Unexpectedly versatile and safe. Mazda5 offers a revolutionary way for weekday warriors, <br/>maverick multi-taskers and parental pioneers to move their lives.]]>
	 </text>

	 ...

	 *
	 * @author Joel Morrison
	 */
	public class PopuliteParser {
		public static var _replacementsIndex : Dictionary;

		public static function parse($x : XML) : PopulateVO {
			$x.ignoreComments = true;
			$x.ignoreWhitespace = true;
			if($x..CharReplacements) {
				_replacementsIndex = new Dictionary();
				for each(var f : XML in $x..CharReplacements..font) {
					var fontindex : Dictionary = new Dictionary();
					for each(var option : XML in f..option) {
						fontindex[option.@char + ''] = option.@replace + '';
					}
					_replacementsIndex[f.@name + ''] = fontindex;
				}
			}

			var populateVO : PopulateVO = new PopulateVO();

			populateVO.lexicon = new Dictionary();
			populateVO.colors = new Dictionary();
			populateVO.styles = new Dictionary();

			for each(var c : XML in $x..GlobalColors..color) {
				populateVO.colors['' + c.@id] = parseInt(('' + c.@color).split('#').join('0x'), 16);
			}

			for each(var l : XML in $x..TextContent..text) {
				var tvo : TextVO = new TextVO();
				if('' + l.@weight != '') {
					tvo.bold = ('' + l.@weight == "bold");
				}
				else {
					if('' + l.@bold != '') tvo.bold = ('' + l.@bold == "true");
				}
				tvo.variant = '' + l.@variant;
				tvo.font = '' + l.@font;
				tvo.content = '' + l;
				tvo.id = '' + l.@id;
				if(l.attribute("align") != undefined)tvo.align = '' + l.@align;
				if(l.attribute("x") != undefined) tvo.x = Number('' + l.@x);
				if(l.attribute("y") != undefined) tvo.y = Number('' + l.@y);
				if(l.attribute("upperCase") != undefined)tvo.upperCase = '' + l.@upperCase == "true";
				if(l.attribute("antiAliasTypeAdvanced") != undefined)tvo.antiAliasTypeAdvanced = '' + l.@antiAliasTypeAdvanced == "true";
				if(l.attribute("pixelSnap") != undefined)tvo.pixelSnap = '' + l.@pixelSnap == "true";
				if(l.@leading)tvo.leading = parseInt('' + l.@leading);
				if(l.@size)tvo.size = parseInt('' + l.@size);
				if(l.@alpha)tvo.alpha = Number('' + l.@alpha);
				if(l.@thickness)tvo.thickness = Number('' + l.@thickness);
				if(l.attribute("width"))tvo.width = parseInt('' + l.@width);
				if(l.@letterSpacing) {
					tvo.letterSpacing = Number('' + l.@letterSpacing);
				}
				else {
					tvo.letterSpacing = 0;
				}
				if(l.@kerning) {
					tvo.kerning = '' + l.@kerning == "true";
				}
				else {
					tvo.kerning = true;
				}
				if(l.@underline)tvo.underline = '' + l.@underline == "true";
				if(l.@colorID && populateVO.colors[l.@colorID + '']) {
					tvo.color = populateVO.colors[l.@colorID + ''];
				}
				else if(l.@color) {
					tvo.color = parseInt(('' + l.@color).split('#').join('0x'), 16);
					tvo.colorHex = '' + l.@color;
				}

				tvo.content = replaceContent(tvo.content, tvo.font);


				// add the text color to the global colors dictionary
				populateVO.colors['' + l.@id] = tvo.color;
				populateVO.lexicon[tvo.id] = tvo;
			}

			for each(var ss : XML in $x..CSS..styleSheet) {
				var keys : Array = new Array();
				var css : StyleSheet = new StyleSheet();
				for each (var s : XML in ss..style) {
					trace('' + 's = ' + s);
					var style : Object = new Object();
					if(s.@weight == 'bold')style.fontWeight = "bold";
					if(s.@size)style.fontSize = parseInt('' + s.@size);
					if(s.@family) {
						style.fontFamily = '' + s.@family;
						trace('' + 's.@family = ' + s.@family);
						trace('' + 'style.fontFamily = ' + style.fontFamily);
					}
					if(s.@color) {
						style.color = s.@color;
						populateVO.colors['' + ss.@id] = parseInt(('' + ss.@color).split('#').join('0x'), 16);
					}
					css.setStyle(s.@name + '', style);
				}
				keys.push('' + ss.@id);
				populateVO.styles['' + ss.@id] = css;
			}
			populateVO.styles['keys'] = keys;

			//if($x..Fonts && $x..Fonts[0].@embedded) populateVO.embedded=('' + $x..Fonts[0].@embedded == "true");

			return populateVO;
		}

		public static function replaceContent(content : String, $font : String) : String {
			if(_replacementsIndex && content && content.toLowerCase().indexOf("</") == -1) {
				var rIndex : Dictionary = _replacementsIndex[$font];
				if(rIndex) {
					var replacementsArr : Array = [];
					var charArr : Array = [];
					for(var key : Object in rIndex) {
						charArr = [key + '',rIndex[key + '']];
						replacementsArr.push(charArr);
						content = content.split(key + '').join(rIndex[key + '']);
					}
				}
			}
			return content;
		}
	}
}