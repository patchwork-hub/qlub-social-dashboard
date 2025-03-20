document.addEventListener('DOMContentLoaded', function () {
  var editButtons = document.querySelectorAll('[data-target="#communityAdminModal"]');
  var form = document.querySelector('#new_admin_form');
  const emailField = document.querySelector('#community_admin_email');

  // Function to update the role field based on checkbox selection
  window.updateRoleField = function (checkbox) {
    const roleField = document.querySelector('#community_admin_role');

    if (checkbox.id === 'is_organisation_admin' && checkbox.checked) {
      roleField.value = 'OrganisationAdmin';
    } else if (checkbox.id === 'is_hub_admin' && checkbox.checked) {
      roleField.value = 'HubAdmin';
    } else {
      roleField.value = '';
    }
  };

  editButtons.forEach(function (button) {
    button.addEventListener('click', function () {
      var adminId = this.getAttribute('data-admin-id');
      var email = this.getAttribute('data-email');
      var password = this.getAttribute('data-password');
      var role = this.getAttribute('data-role');
      var isBoostBot = this.getAttribute('data-is-boost-bot') === 'true';

      // Populate the form fields
      emailField.value = email || '';

      const passwordField = document.querySelector('#community_admin_password');
      if (passwordField) {
        passwordField.value = password || '';
      }
      const roleField = document.querySelector('#community_admin_role');
      roleField.value = role || '';

      const isOrganisationAdminCheckbox = document.querySelector('#is_organisation_admin');
      const isHubAdminCheckbox = document.querySelector('#is_hub_admin');
      const isBoostBotCheckbox = document.querySelector('#community_admin_is_boost_bot');

      if (adminId) {
        // Edit mode: set checkboxes based on existing admin data
        if (isOrganisationAdminCheckbox) {
          isOrganisationAdminCheckbox.checked = role === 'OrganisationAdmin';
        }
        if (isHubAdminCheckbox) {
          isHubAdminCheckbox.checked = role === 'HubAdmin';
        }
        if (isBoostBotCheckbox) {
          isBoostBotCheckbox.checked = isBoostBot;
        }

        form.setAttribute('action', '/community_admins/' + adminId);
        form.setAttribute('method', 'post');
        emailField.readOnly = true;

        // Add or update the hidden _method field for PATCH
        let methodInput = document.querySelector('input[name="_method"]');
        if (!methodInput) {
          methodInput = document.createElement('input');
          methodInput.setAttribute('type', 'hidden');
          methodInput.setAttribute('name', '_method');
          form.appendChild(methodInput);
        }
        methodInput.setAttribute('value', 'patch');

        document.querySelector('.modal-title').innerHTML = 'Edit channel admin';
      } else {
        // Create mode: set checkboxes to default true
        if (isOrganisationAdminCheckbox) {
          isOrganisationAdminCheckbox.checked = true;
          document.querySelector('#community_admin_role').value = 'OrganisationAdmin';
        }
        if (isHubAdminCheckbox) {
          isHubAdminCheckbox.checked = true;
          document.querySelector('#community_admin_role').value = 'HubAdmin';
        }
        if (isBoostBotCheckbox) {
          isBoostBotCheckbox.checked = true; // Default to true for "Create"
        }

        roleField.value = '';

        form.setAttribute('action', '/community_admins');
        form.setAttribute('method', 'post');
        emailField.readOnly = false;

        // Remove the _method field if it exists
        let methodInput = document.querySelector('input[name="_method"]');
        if (methodInput) methodInput.remove();

        document.querySelector('.modal-title').innerHTML = 'Create channel admin';
      }
    });
  });
});
