// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks 
//= require jquery_ujs
//= require owl.carousel
//= require bootstrap
//= require jquery-ui/autocomplete
//= require autocomplete-rails
//= require annotator

//= require turbolinks
//= require_tree .
//= require jquery.contextMenu
//= require jquery.ui.position

$(function() {
  // Ajax search and filtering

  $("#accounts p a, #accounts .pagination a").on("click", function() {
    $.getScript(this.href);
    return false;
  });
  $("#accounts_search").submit(function() {
    $.get(this.action, $(this).serialize(), null, "script");
    return false;
  });

  /*
  $("#papers p a, #papers .pagination a").on("click", function() {
    $.getScript(this.href);
    return false;
  });
  $("#papers_search").submit(function() {
    $.get(this.action, $(this).serialize(), null, "script");
    return false;
  });*/

  // Profile tabs
  $('#myTabs a').click(function (e) {
    e.preventDefault()
    $(this).tab('show')
  });  

});

