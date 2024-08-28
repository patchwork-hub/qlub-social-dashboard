document.addEventListener('DOMContentLoaded', function() {
  window.reload_contributors_table = function(url) {
    console.log("page url" + url);
    $.ajax({
      url: url,
      method: 'GET',
      success: function(response) {
        var contributors_table = $('#followed_contributors_table');
        contributors_table.html(response);
      },
      error: function() {
        console.log('Error occurred while unfollowing contributor');
      }
    });
  }
});