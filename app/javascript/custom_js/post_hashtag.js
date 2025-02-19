document.addEventListener('DOMContentLoaded', function() {
  const editLinks = document.querySelectorAll('.edit-link');

  editLinks.forEach(link => {
    link.addEventListener('click', function() {
      const hashtag = this.getAttribute('data-hashtag');
      const id = this.getAttribute('data-id');
      const community_id = this.getAttribute('data-community-id');

      // Populate the form fields in the modal
      document.getElementById('post_hashtag_id').value = id;
      document.getElementById('post_hashtag_name').value = hashtag;

      // Update the form action URL dynamically
      const form = document.querySelector('#postHashtagEditModel form');
      form.action = `/channels/${community_id}/post_hashtags/${id}`;
    });
  });
});
