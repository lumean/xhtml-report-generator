/* "THE BEER-WARE LICENSE" (Revision 42): 
 * <m-widmer@gmx> wrote this file. As long as you retain this notice you 
 * can do whatever you want with this stuff. If we meet some day, and you think 
 * this stuff is worth it, you can buy me a beer in return Manuel Widmer
 */

// automatically generate TOC when document is ready
// use http://closure-compiler.appspot.com/home  to make jscript code smaller

/* The following conventions must be followed in order to support 
   automatic TOC generation and heading numbers

   The script will generate two TOCs, each one of them residing in a <div id=xyz></div>
   the id has to bei either "ltoc" or "rtoc" (left or right table of content)
   Headers h1 to h3 are automatically numbered in 1.1.1 style
   ltoc includes the numbers, whereas rtoc only has unnumbered headings
   
   Ther are two predefined classes for headings. 
   appear in the ltoc only: no special class needed
   appear in the rtoc only: class="onlyrtoc"
   appear in both tocs:     class="bothtoc"
   <h2 class="rtoconly">This title will only appear in rtoc</h2>
   
   In addition the script can create quicklinks to the most recent h1 or h2 tag.
   use the classes "h1" or "h2" respectively:
   <a class="h1" >hyperlink to most recent h1</a>
*/
$(document).ready(function() {
    // to include new chaptes in the right div tag use class=rtoconly or bothtoc
	$("[class=rtoconly],[class=bothtoc]").each(function(i) {
		//alert("h1:"+i);
		var current = $(this);  // refer to the current <h1> element
		// set the id
        type = current.attr("class");
		current.attr("id", type + i);
		$("#rtoc").append("<a href='#" + type + i + "'>" + 
			current.html() + "</a> <br />\n");
			//current.html returns everything between <h1> </h1>
	});	

	// global counter for auto-numbering the chapters:
	h1index = 0;
	h2index = 0;
	h3index = 0;
	
    // scan the document top down 
    // i = starting at 0 increases for each matched tag / class
	$("h1, h2, h3, a.h2, a.h1").each(function(i) {
		var current = $(this);// refer to the current <hX> or <a> element
        // use correct id if it was already defined by bothtoc or define ltoc id
        if (current.attr("id") == undefined) {
           current.attr("id","title"+i); //ltoc id
        } 
		// autonumbering + ltoc to previous chapters (h1,h2,h3)
		if ("h1" == current.prop("tagName")) {
			// auto numbering
			h1index += 1;
			h2index = 0;
			h3index = 0;
			current.prepend(h1index + " "); // prepend Number
			$("#ltoc").append("<br />\n"); // add line break to ltoc
			// save the link to the previous <h1>
			lasth1 = "#" + current.attr("id");
			lasth1cont = current.html();
		} else if ("h2" == current.prop("tagName")) {
			h2index += 1;
			h3index = 0;
			current.prepend(h1index + "." + h2index + " ");
			lasth2 = "#" + current.attr("id");
			lasth2cont = current.html();
		} else if ("h3" == current.prop("tagName")) {
			h3index += 1;
			current.prepend(h1index + "." + h2index + "." + h3index + " ");
		} else if(current.attr("class") == "h1") {
			current.attr("href", lasth1);
			current.html(lasth1cont); // add hyperlink to last h1 tag
			return 0;
		} else if(current.attr("class") == "h2") {
			current.attr("href", lasth2);
			current.html(lasth2cont); // add hyperlink to last h2 tag
			return 0;
		}
		
		// exclude rtoconly from ltoc
		if (current.attr("class") == "rtoconly") {
			return 0;// we have to use return 0 b/c we are in a callback function
		}

        $("#ltoc").append("<a id='link" + i + "' href='#" + current.attr("id")
                       + "' >" + current.html() + "</a> <br />\n"); 
        return 0;
	});
});



