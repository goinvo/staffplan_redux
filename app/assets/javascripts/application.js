//= require moment/moment
//= require jquery/dist/jquery
//= require jquery-ujs/src/rails
//= require lodash/lodash
//= require handlebars.runtime
//= require knockoutjs/dist/knockout.debug
//= require_tree ./templates
//= require_tree ./models
//= require_tree ./views
//= require_tree ./components
//= require shared/flashes
//= require_self

function hashParam(key) {
  return _.reduce(window.location.hash.slice(1).split('&'), function(params, keyValue) {
    params[keyValue.split('=')[0]] = keyValue.split('=')[1];
    return params;
  }, {})[key]
}
