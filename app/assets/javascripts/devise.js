//= require jquery/dist/jquery
//= require jquery-ujs/src/rails
//= require shared/flashes
//= require_self

function hashParam(key) {
  return _.reduce(window.location.hash.slice(1).split('&'), function(params, keyValue) {
    params[keyValue.split('=')[0]] = keyValue.split('=')[1];
    return params;
  }, {})[key]
}
