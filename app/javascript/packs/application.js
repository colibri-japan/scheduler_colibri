/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import "core-js/stable";
import "regenerator-runtime/runtime";

import './bootstrap_custom.js'
import "controllers"

require("@rails/ujs").start()
require("turbolinks").start()

import '../application/stylesheets/application.css'

import '../application/javascripts/general_javascript.js'
import '../application/javascripts/posts.js'
import '../application/javascripts/selectize_functions.js'
import '../application/javascripts/turbolinks_scroll.js'

import 'arrive'

$(document).arrive(".fc-list-empty", function () {
    $('#no-appointments-today').show()
})

$(document).arrive(".fc-list-table", function () {
    $('#no-appointments-today').hide()
})

$(document).arrive(".fc-view > table", function () {
    $('#no-appointments-today').hide()
})
