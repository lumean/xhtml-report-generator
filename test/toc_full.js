/* "THE BEER-WARE LICENSE" (Revision 42): 
 * <m-widmer@gmx> wrote this file. As long as you retain this notice you 
 * can do whatever you want with this stuff. If we meet some day, and you think 
 * this stuff is worth it, you can buy me a beer in return Manuel Widmer
 */

// automatically generate TOC when document is ready
// use http://closure-compiler.appspot.com/home  to make jscript code smaller

/* The following conventions must be followed in order to support 
   automatic TOC generation and heading numbers

   The script will generate two tables of content (TOCs), each one of them residing in a <div id=xyz></div>
   the id has to be either "ltoc" or "rtoc" (left or right table of content)
   Headers h1 to h3 are automatically numbered in 1.1.1 style
   ltoc includes the numbers, whereas rtoc only has unnumbered headings
   
   There are two predefined classes for headings. 
   appear in the ltoc only: no special class needed
   appear in the rtoc only: class="rtoconly"
   appear in both tocs:     class="bothtoc"
   example:
   <h2 class="rtoconly">This title will only appear in the toc on the right</h2>
   
   The script can create jumplinks to the most recent h1 or h2 tag.
   use the classes "h1" or "h2" in an anchor tag:
   <a class="h1">hyperlink to most recent h1</a>
   
   It will also set the background-color attribute of <td> elements of tables containing
   "passed", "failed", or "check" with green, red, or yellow respectively
*/
$(document).ready(function() {
	// highlight "passed", "failed", or "check" in any table
	$("td").each(function(i) {
		var current = $(this);
		if (!(current.html().match(/^passed$/) === null)) {
			current.attr("style", "background-color:#19D119;");  //green
		} else if (!(current.html().match(/^failed$/) === null)) {
			current.attr("style", "background-color:#FF4719;");  //red
		} else if (!(current.html().match(/^check$/) === null)) {
            current.attr("style", "background-color:#FFFF00;");  //yellow
        }
	});
	
    // to include new chapters in the right div tag use class=rtoconly or bothtoc
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



