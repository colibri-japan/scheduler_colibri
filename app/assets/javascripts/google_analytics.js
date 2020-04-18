document.addEventListener('turbolinks:load', function () {
    if (typeof gtag === 'function') {
        console.log('type of gtag is function')
        gtag('config', 'UA-136584111-3')
    } else {
        console.log('gtag is not a function')
    }
    console.log('firing config anyways')
    gtag('config', 'UA-136584111-3')
});