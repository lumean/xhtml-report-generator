
// there should be a button with id='pre_toggle_linewrap'

$(document).ready(function() {  // add toggle linewrap functionality
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
});
