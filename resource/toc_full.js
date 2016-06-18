/* "THE BEER-WARE LICENSE" (Revision 42): 
 * <m-widmer@gmx> wrote this file. As long as you retain this notice you 
 * can do whatever you want with this stuff. If we meet some day, and you think 
 * this stuff is worth it, you can buy me a beer in return - Manuel Widmer
 */

// automatically generate TOC when document is ready
// use http://closure-compiler.appspot.com/home  to make jscript code smaller

/* The following conventions must be followed in order to support 
   automatic TOC generation and heading numbers.
   
   This script requires jquery (tested with version 1.12.4.min.js)

   The script will generate two tables of content (TOCs), each one of them residing in a <div id=xyz></div>
   the id has to be either "ltoc" or "rtoc" (left or right table of content)
   Headers h1 to h3 are automatically numbered in 1.1.1 style
   ltoc includes the numbers, whereas rtoc only has unnumbered headings (e.g. quicklinks)
   
   So all you have to do is to include on your homepage somewhere the <div> as follows:
   <div id='ltoc'> Table of Contents: <br /> </div>
   <div id='rtoc'> Quicklinks: <br /> </div>
   
   All the content will then be added automatically by the script below
      
   There are two predefined classes for headings. 
   appear in the ltoc only: no special class needed, by default all h1, h2 and h3 will be indexed
   appear in the rtoc only: class="rtoconly"
   appear in both tocs:     class="bothtoc"
   example:
   <h2 class="rtoconly">This title will only appear in the toc on the right</h2>
   
   The script can create jumplinks to the most recent h1 or h2 tag.
   use the classes "h1" or "h2" in an anchor tag:
   <a class="h1">hyperlink to most recent h1</a>
   
   <a class="h2">hyperlink to most recent h2</a>
   
   It will also set the background-color attribute of <td> elements of tables containing
   "passed", "failed", or "check" with green, red, or yellow respectively
*/

$(document).ready(function() {

    // for split.js
    Split(['#ltoc', '#middle', '#rtoc'], {
      minSize: [5,10,5],
      sizes: [20, 70, 10],
      snapOffset: 50,
      gutterSize: 10,
    })
  
  
	// highlight "passed", "failed", or "check" in any table
	$("td").each(function(i) {
		var current = $(this);
		if (!(current.html().match(/^passed$/i) === null)) {
			current.attr("style", "background-color:#19D119;");  //green
		} else if (!(current.html().match(/^failed$/i) === null)) {
			current.attr("style", "background-color:#FF4719;");  //red
		} else if (!(current.html().match(/^check$/i) === null)) {
      current.attr("style", "background-color:#FFFF00;");  //yellow
    }
	});
	
	// below section includes headings or elements with the corresponding class
	// to the right hand toc (aka. quicklinks)
  // to include new chapters in the right div tag use class=rtoconly or bothtoc
	$("[class=rtoconly],[class=bothtoc]").each(function(i) {
		//alert("h1:"+i); // i is just a counter that increments for each match 
		var current = $(this);  // refer to the current <h1> element
		// set the id
    var type = current.attr("class");
		current.attr("id", type + i);  // e.g. id="bothtoc3"
		$("#rtoc").append("<a href='#" + type + i + "'>" + 
			current.html() + "</a> <br />\n");
			//current.html returns everything between <h1> </h1>
	});	

	// global counter (i.e. no "var") for auto-numbering the chapters:
	h1index = 0;
	h2index = 0;
	h3index = 0;
	
  // reason for .toUpperCase() string comparison instead of .toLowerCase()
  // https://msdn.microsoft.com/en-us/library/bb386042.aspx
  // https://en.wikipedia.org/wiki/Capital_%E1%BA%9E
  
  // below section generates/fills the left table of content (ltoc)
  // scan the document top down 
  // i = starting at 0 increases for each matched tag / class
	$("h1, h2, h3, a.h2, a.h1").each(function(i) {
		var current = $(this);// refer to the current <hX> or <a> element
    // use correct id if it was already defined by bothtoc or define ltoc id
    if (current.attr("id") == undefined) {
       current.attr("id", "title"+i); //ltoc id
    } 
		// autonumbering + ltoc to previous chapters (h1,h2,h3)
		if ("H1" == current.prop("tagName").toUpperCase()) {
			// auto numbering
			h1index += 1;
			h2index = 0;
			h3index = 0;
			current.prepend(h1index + " "); // prepend Number
			$("#ltoc").append("<br />\n"); // add line break to ltoc
			// save the link to the previous <h1>
			lasth1 = "#" + current.attr("id");
			lasth1cont = current.html();
		} else if ("H2" == current.prop("tagName").toUpperCase()) {
			h2index += 1;
			h3index = 0;
			current.prepend(h1index + "." + h2index + " ");
			lasth2 = "#" + current.attr("id");
			lasth2cont = current.html();
		} else if ("H3" == current.prop("tagName").toUpperCase()) {
			h3index += 1;
			current.prepend(h1index + "." + h2index + "." + h3index + " ");
		} else if(current.attr("class").toUpperCase() == "H1") {
			current.attr("href", lasth1);
			current.html(lasth1cont); // add hyperlink to last h1 tag
			return 0;
		} else if(current.attr("class").toUpperCase() == "H2") {
			current.attr("href", lasth2);
			current.html(lasth2cont); // add hyperlink to last h2 tag
			return 0;
		}
		
		// exclude rtoconly from ltoc
    if (typeof current.attr("class") != 'undefined') {
      if (current.attr("class").toUpperCase() == "RTOCONLY") {
        return 0;// we have to use return 0 b/c we are in a callback function
      }
    }

    // add the quicklink to the ltoc
    // for ltoc insert also a folding -/+ hyperlink
    // to be able to fold properly with the jquery toggle() method, we put
    // both hyperlinks (foling & chapter) into a div tag which we then can toggle
    // note the href has to be empty, otherwise the document ready will trigger upon click
    // and this function will override the html which was just added by the click function below
    $("#ltoc").append("<div id='div_fold_"+h1index+"_"+h2index+"_"+h3index+"'>"
          + "<a id='a_fold_"+h1index+"_"+h2index+"_"+h3index+"' style='cursor:pointer'>&#160;-&#160;</a> "
          + "<a id='link" + i + "' href='#" + current.attr("id")
          + "' >" + current.html() + "</a> <br /> </div>\n"); 
    return 0;
	}); // $("h1, h2, h3, a.h2, a.h1").each
  
  // add toggle linewrap functionality
  pre_style = false;
  $('#pre_toggle_linewrap').click(function() {
    if (pre_style) {
      $("pre").css({"white-space":"pre-wrap", "word-wrap":"break-word"});
      pre_style = false;
    } else {
      $("pre").css({"white-space":"pre", "word-wrap":"initial"});
      pre_style = true;
    }
  });//end toggle line wrap
  
  
  // implements folding button for elements in ltoc
  $('a[id^="a_fold"]').click(function() {
    var current = $(this);  // refers to the a tag
    // grab the current chapter indices from the id
    var arr = current.attr("id").match(/(\d+)_(\d+)_(\d+)/);
    //alert(arr.join('\n'))
    
    if (current.html().match(/-/)) {
      var content = "&#160;+&#160;"
      var show = false; // hide
      current.html(content);
      
    } else {
      var content = "&#160;-&#160;"
      var show = true; // show
      current.html(content);
    }
        
    // check which index equals zero and hide all sub chapters
    if (arr[2]=="0") {
      // toggle all h2 below current h1
      // everything that contains index1 = arr[1] and index2 not zero
      var re = new RegExp("div_fold_"+arr[1]+"_[1-9]\\d*_0");
      $("div").filter(function(){return this.id.match(re)}).each(function() {
        $(this).children('a[id^="a_fold"]').html(content)
        $(this).toggle(show)
      });
      // toggle all h3 below current h1
      // h1 can have h3 children without any h2, so toggle also all items where index 3 
      var re = new RegExp("div_fold_"+arr[1]+"_\\d+_[1-9]\\d*");
      $("div").filter(function(){return this.id.match(re)}).each(function() {
        $(this).children('a[id^="a_fold"]').html(content)
        $(this).toggle(show)
      });
    } else if (arr[3]=="0") {
      // only toggle all h3 below current h2
      // hide everything that contains index1 = arr[1] and index2 = arr[2] and index3 not zero
      var re = new RegExp("div_fold_"+arr[1]+"_"+arr[2]+"_[1-9]\\d*");
      $("div").filter(function(){return this.id.match(re)}).each(function() {
        $(this).children('a[id^="a_fold"]').html(content)
        $(this).toggle(show)
      });
    } 
  }); // click toc chapter folding
  
  
});




