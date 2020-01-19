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

    $('.activity_subheader_item ').click(function(){
        $('.activity_subheader_item ').removeClass('activity_subheader_item_selected')
        $(this).addClass('activity_subheader_item_selected')
    })

    if ($('#daily-completion-reports-container').length > 0) {
        $.getScript(`/completion_reports.js?day=${moment().format('YYYY-MM-DD')}`)
    }

    $('#posts_item_selected').click(function(){
        $('#posts-widget-container').show()
        $('#daily-completion-reports-container').hide()
        $(".activity_body").scrollTop($("#posts-container")[0].scrollHeight)
    })

    $('#completion_reports_selected').click(function(){
        $('#posts-widget-container').hide()
        $('#daily-completion-reports-container').show()
    })

    $(document).on("mousedown", "[data-ripple]", function(e){
        var $self = $(this);

        if ($self.is(".btn-disabled")) {
            return;
        }
        if ($self.closest("[data-ripple]")) {
            e.stopPropagation();
        }

        var initPos = $self.css("position"),
            offs = $self.offset(),
            x = e.pageX - offs.left,
            y = e.pageY - offs.top,
            dia = Math.min(this.offsetHeight, this.offsetWidth, 100), // start diameter
            $ripple = $('<div/>', { class: "ripple", appendTo: $self });

        if (!initPos || initPos === "static") {
            $self.css({ position: "relative" });
        } 
        
        $('<div/>', {
            class: "rippleWave",
            css: {
                background: $self.data("ripple"),
                width: dia,
                height: dia,
                left: x - (dia / 2),
                top: y - (dia / 2),
            },
            appendTo: $ripple,
            one: {
                animationend: function () {
                    $ripple.remove();
                }
            }
        });
    })
})