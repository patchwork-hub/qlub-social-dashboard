document.addEventListener('DOMContentLoaded', function() {
  const editLinks = document.querySelectorAll('.edit-link');
  

  editLinks.forEach(link => {
    link.addEventListener('click', function() {
      // Get data from the link
      const hashtag = this.getAttribute('data-hashtag');
      const id = this.getAttribute('data-id');
      
      // Populate modal fields
      document.getElementById('post_hashtag_id').value = id;
      document.getElementById('post_hashtag_name').value = '#'+hashtag;
    });
  });
});
