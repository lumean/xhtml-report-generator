
// this small script triggers the page rendering with split.js
// it assumes there is somewhere in the DOM an element with id='layout'
// and class=['0','1','2','3']
$(document).ready(function() {
  // for split.js
  switch($("#layout").attr('class')) {
    case "1":
      Split(['#ltoc', '#middle'], {
        minSize: [5, 100],
        sizes: [20, 80],
        snapOffset: 50,
        gutterSize: 10,
      });
      break;
    case "2":
      Split(['#middle', '#rtoc'], {
        minSize: [100, 5],
        sizes: [85, 15],
        snapOffset: 50,
        gutterSize: 10,
      });
      break;
    case "3":
      Split(['#ltoc', '#middle', '#rtoc'], {
        minSize: [5, 100, 5],
        sizes: [20, 70, 10],
        snapOffset: 50,
        gutterSize: 10,
      });
      break;
    default:
      /* unkown format, split is not safe, do nothing*/
      $("#middle").attr("style", "width:100%;");
      //alert($("#layout").attr('class'));
  }
});
