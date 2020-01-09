window.colibriDropdown = function() {
    document.getElementById("colibriDropdown").classList.toggle('show')
}

window.onclick = function(event) {
    if (!event.target.matches('.dropbtn')) {
        var dropdowns = document.getElementsByClassName("colibri-dropdown-content")
        var i;
        for (i = 0; i < dropdowns.length; i++) {
            var openDropdown = dropdowns[i];
            if (openDropdown.classList.contains('dropdown-show')) {
                openDropdown.classList.remove('dropdown-show');
            }
        }
    }
}

window.initializeTooltips = function() {
    $('.colibri-tooltip').each(function () {
        $(this).popover({
            html: true,
            content: $(this).data('content'),
            trigger: 'hover'
        })
    })
}

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

    $('.nurse-subsection-toggleable').click(function(){
        $(this).next().toggle()
        $(this).find('span').toggle()
    })

    $('.nurse-subsection-toggleable p').click(function(e){
        e.stopPropagation()
    })

    $('.header-submenu-item').click(function(){
        $('.header-submenu-item').removeClass('header-submenu-item-selected')
        $(this).addClass('header-submenu-item-selected')
    })
})