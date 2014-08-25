$(function() {
  setTimeout(function() {
    $('.flash-notice, .flash-success').not(":animated").each(function(element) {
      $(this).slideUp('fast');
    });
  }, 5000);
  
  $('a.close').click(function() {
    $(this).closest('.flash').slideUp('fast')
  });
})
