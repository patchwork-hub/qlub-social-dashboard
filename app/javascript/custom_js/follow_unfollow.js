document.addEventListener('DOMContentLoaded', function() {
  window.followContributor = function(account_id) {
    console.log('account_id : ' + account_id)
    $.ajax({
      url: `/accounts/${account_id}/follow`,
      method: 'POST',
      success: function(response) {
        var followBtn = $(`#follow_btn_${account_id}`);
        
        // Change the button text to "Unfollow"
        followBtn.text('Unfollow');
        followBtn.removeClass('btn-outline-dark');
        followBtn.addClass('btn-outline-danger');

        // Optionally, you can change the onclick function to unfollow
        followBtn.attr('onclick', `unfollowContributor(${account_id})`);
      },
      error: function() {
        console.log('Error occurred while following contributor');
      }
    });
  };

  window.unfollowContributor = function(account_id) {
    $.ajax({
      url: `/accounts/${account_id}/unfollow`,
      method: 'POST',
      success: function(response) {
        var followBtn = $(`#follow_btn_${account_id}`);
        
        // Change the button text to "Follow"
        followBtn.text('Follow');
        followBtn.removeClass('btn-outline-danger');
        followBtn.addClass('btn-outline-dark');

        // Optionally, change the onclick function back to follow
        followBtn.attr('onclick', `followContributor(${account_id})`);
      },
      error: function() {
        console.log('Error occurred while unfollowing contributor');
      }
    });
  };
});