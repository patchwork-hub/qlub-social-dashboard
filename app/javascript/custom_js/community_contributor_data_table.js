
document.addEventListener('DOMContentLoaded', function() {
  window.reloadFollowers = function(username) {
    $.ajax({
      url: '/follows',
      method: 'GET',
      data: { q: { username_cont: username } },
      success: function(response) {
        console.log(response);
        var contributors_table = $('#followed_contributors_table');
        contributors_table.html(response);
      },
      error: function() {
        console.log('Error occurred while fetching contributors');
      }
    });
  };
});


