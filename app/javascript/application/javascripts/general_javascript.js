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



})