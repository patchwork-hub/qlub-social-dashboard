
document.addEventListener('DOMContentLoaded', function() {
  window.reloadFollowers = function(username) {
    $.ajax({
      url: '/follows',
      method: 'GET',
      data: { q: { username_cont: username } },
      success: function(response) {
        var contributors_table = $('#contributors_table');
        contributors_table.html(response);
      },
      error: function() {
        console.log('Error occurred while fetching contributors');
      }
    });
  };
});


