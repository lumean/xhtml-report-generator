
// highlight "passed", "failed", or "check" in any table
// It will also set the background-color attribute of <td> elements of tables containing
// "passed", "failed", or "check" with green, red, or yellow respectively
$(document).ready(function() {
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
});
