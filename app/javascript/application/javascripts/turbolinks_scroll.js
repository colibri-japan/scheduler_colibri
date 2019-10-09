require("turbolinks").start()

let scrollPosition

document.addEventListener('turbolinks:load', function () {
    if (scrollPosition) {
        window.scrollTo.apply(window, scrollPosition)
        scrollPosition = null
    }
}, false)

Turbolinks.reload = () => {
    scrollPosition = [window.scrollX, window.scrollY]
    Turbolinks.visit(window.location)
}

let resourceScroll

document.addEventListener('turbolinks:load', function () {
    menu_presence_condition = $('#resource-container').length > 0
    if (window.resourceScroll && menu_presence_condition) {
        $('#resource-container').scrollTop(window.resourceScroll);
        window.resourceSroll = null
    }
})