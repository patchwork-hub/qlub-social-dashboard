document.addEventListener('DOMContentLoaded', function () {
  var editButtons = document.querySelectorAll('[data-target="#communityAdminModal"]');
  var form = document.querySelector('#new_admin_form');

  editButtons.forEach(function (button) {
    button.addEventListener('click', function () {
      var adminId = this.getAttribute('data-admin-id');
      var displayName = this.getAttribute('data-display-name');
      var username = this.getAttribute('data-username');
      var email = this.getAttribute('data-email');
      var password = this.getAttribute('data-password');
      var role = this.getAttribute('data-role');

      // Populate the form fields
      document.querySelector('#community_admin_display_name').value = displayName || '';
      document.querySelector('#community_admin_username').value = username || '';
      document.querySelector('#community_admin_email').value = email || '';
      document.querySelector('#community_admin_password').value = password || '';
      document.querySelector('#community_admin_role').value = role || '';

      if (adminId) {
        // Edit mode
        form.setAttribute('action', '/community_admins/' + adminId);
        form.setAttribute('method', 'post');

        // Add or update the hidden _method field for PATCH
        let methodInput = document.querySelector('input[name="_method"]');
        if (!methodInput) {
          methodInput = document.createElement('input');
          methodInput.setAttribute('type', 'hidden');
          methodInput.setAttribute('name', '_method');
          form.appendChild(methodInput);
        }
        methodInput.setAttribute('value', 'patch');

        document.querySelector('.modal-title').innerHTML = 'Edit Community Admin';
      } else {
        // Create mode
        form.setAttribute('action', '/community_admins');
        form.setAttribute('method', 'post');

        // Remove the _method field if it exists
        let methodInput = document.querySelector('input[name="_method"]');
        if (methodInput) methodInput.remove();

        document.querySelector('.modal-title').innerHTML = 'Create Community Admin';
      }
    });
  });
});
