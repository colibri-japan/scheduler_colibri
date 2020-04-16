window.colibriDropdown = function() {
  document.getElementById("colibriDropdown").classList.toggle('show')
}

window.colibriMobileDropdown = function() {
  var display = document.getElementById("colibri-mobile-submenu").style.display
  if (display === 'none') {
    document.getElementById("colibri-mobile-submenu").style.display = 'block'
  } else {
    document.getElementById("colibri-mobile-submenu").style.display = 'none'
  }
}

window.colibriMobileShowDropdown = function() {
  document.getElementById("hamburger-nav-mobile").style.display = 'none'
  document.getElementById("close-nav-mobile").style.display = 'block'
  document.getElementById("colibri-mobile-menu").style.display = 'block'
}

window.colibriMobileHideDropdown = function() {          
  document.getElementById("hamburger-nav-mobile").style.display = 'block'
  document.getElementById("close-nav-mobile").style.display = 'none'
  document.getElementById("colibri-mobile-menu").style.display = 'none'
}

window.setTimeout(function() {
    document.getElementById('flash').style.display ='none'
}, 2500);