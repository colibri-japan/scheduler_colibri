

let clickableTableRowPost = () => {
  $('tr.post-clickable-row').click(function() {
    $.getScript($(this).data('url'));
  });
};
window.clickableTableRowPost = clickableTableRowPost

let clickablePost = () => {
  $('.post-clickable').click(function(){
    $.getScript($(this).data('url'))
  })
}
window.clickablePost = clickablePost

document.addEventListener('turbolinks:load', function(){
    if ($('#posts-widget-container').length > 0) {
        $.getScript('/posts_widget.js')
    }

    if ($('#index-container').length > 0) {
        clickableTableRowPost() 
    }


})

