document.addEventListener('turbolinks:load', function () {
    $('.btn-scroll').click(function(){
        var aTag = $("#" + $(this).data('anchor'));
        $('html,body').animate({ scrollTop: aTag.offset().top }, 'slow')
    })

    $('#hamburger-nav-mobile').click(function(){
        $(this).hide()
        $('#close-nav-mobile').show()
        $('#colibri-mobile-menu').show()
    })

    $('#close-nav-mobile').click(function(){
        $(this).hide()
        $('#hamburger-nav-mobile').show()
        $('#colibri-mobile-menu').hide()
    })

    $('.toggle-submenu').click(function(){
        $(this).next().toggle()
    })

})