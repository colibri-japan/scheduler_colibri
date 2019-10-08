let postSelectize = () => {
    $('#post_patient_id').selectize({
        plugins: ['remove_button']
    });
}
window.postSelectize = postSelectize

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

    $('#posts_author_ids_filter').selectize({
        plugins: ['remove_button']
    })

    $('#posts_patient_ids_filter').selectize({
        plugins: ['remove_button'] 
    })

    if ($('#index-container').length > 0) {
        clickableTableRowPost() 
    }


})

