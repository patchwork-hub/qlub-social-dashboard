document.addEventListener("DOMContentLoaded", function () {
  var Buttons = document.querySelectorAll(
    '[data-target="#communityAdminModal"]'
  );
  var form = document.querySelector("#new_admin_form");
  const emailField = document.querySelector("#community_admin_email");
  const displayNameField = document.querySelector(
    "#community_admin_display_name"
  );
  const usernameField = document.querySelector("#community_admin_username");

  // Function to update the role field based on checkbox selection
  window.updateRoleField = function (checkbox) {
    const roleField = document.querySelector("#community_admin_role");

    if (checkbox.id === "is_organisation_admin" && checkbox.checked) {
      roleField.value = "OrganisationAdmin";
    } else if (checkbox.id === "is_user_admin" && checkbox.checked) {
      roleField.value = "UserAdmin";
    } else if (checkbox.id === "is_hub_admin" && checkbox.checked) {
      roleField.value = "HubAdmin";
    } else if (checkbox.id === "is_newsmast_admin" && checkbox.checked) {
      roleField.value = "NewsmastAdmin";
    } else {
      roleField.value = "";
    }
  };

  Buttons.forEach(function (button) {
    button.addEventListener("click", function () {
      var adminId = this.getAttribute("data-admin-id");
      var email = this.getAttribute("data-email");
      var displayName = this.getAttribute("data-display-name");
      var username = this.getAttribute("data-username");
      var password = this.getAttribute("data-password");
      var role = this.getAttribute("data-role");
      var isBoostBot = this.getAttribute("data-is-boost-bot") === "true";

      const hideBoostBot = this.getAttribute("data-hide-boost-bot") === "true";
      const boostBotWrapper = document.querySelector(
        "#is_boost_bot_checkbox_wrapper"
      );

      // Populate the form fields
      emailField.value = email || "";

      const passwordField = document.querySelector("#community_admin_password");
      if (passwordField) {
        passwordField.value = password || "";
      }
      const roleField = document.querySelector("#community_admin_role");
      roleField.value = role || "";

      const isOrganisationAdminCheckbox = document.querySelector(
        "#is_organisation_admin"
      );
      const isUserAdminCheckbox = document.querySelector("#is_user_admin");
      const isHubAdminCheckbox = document.querySelector("#is_hub_admin");
      const isNewsmastAdminCheckbox =
        document.querySelector("#is_newsmast_admin");
      const isBoostBotCheckbox = document.querySelector(
        "#community_admin_is_boost_bot"
      );

      if (boostBotWrapper) {
        if (hideBoostBot) {
          boostBotWrapper.style.display = "none";
        } else {
          boostBotWrapper.style.display = "";
        }
      }

      if (adminId) {
        // Edit mode: set checkboxes based on existing admin data
        if (isOrganisationAdminCheckbox) {
          isOrganisationAdminCheckbox.checked = role === "OrganisationAdmin";
        }
        if (isUserAdminCheckbox) {
          isUserAdminCheckbox.checked = role === "UserAdmin";
        }
        if (isHubAdminCheckbox) {
          isHubAdminCheckbox.checked = role === "HubAdmin";
        }
        if (isNewsmastAdminCheckbox) {
          isNewsmastAdminCheckbox.checked = role === "NewsmastAdmin";
        }
        if (isBoostBotCheckbox) {
          isBoostBotCheckbox.checked = isBoostBot;
        }

        form.setAttribute("action", "/community_admins/" + adminId);
        form.setAttribute("method", "post");

        displayNameField.value = displayName;
        usernameField.value = username;
        usernameField.readOnly = true;
        emailField.readOnly = true;

        // Add or update the hidden _method field for PATCH
        let methodInput = document.querySelector('input[name="_method"]');
        if (!methodInput) {
          methodInput = document.createElement("input");
          methodInput.setAttribute("type", "hidden");
          methodInput.setAttribute("name", "_method");
          form.appendChild(methodInput);
        }
        methodInput.setAttribute("value", "patch");

        document.querySelector(".modal-title").innerHTML = "Edit admin";
      } else {
        // Create mode: set checkboxes to default true
        const roleField = document.querySelector("#community_admin_role");

        if (isOrganisationAdminCheckbox) {
          isOrganisationAdminCheckbox.checked = true;
          roleField.value = "OrganisationAdmin";
        } else if (isUserAdminCheckbox) {
          isUserAdminCheckbox.checked = true;
          roleField.value = "UserAdmin";
        } else if (isHubAdminCheckbox) {
          isHubAdminCheckbox.checked = true;
          roleField.value = "HubAdmin";
        } else if (isNewsmastAdminCheckbox) {
          isNewsmastAdminCheckbox.checked = true;
          roleField.value = "NewsmastAdmin";
        }

        if (isBoostBotCheckbox) {
          if (hideBoostBot) {
            displayNameField.value = null;
            usernameField.value = null;
            isBoostBotCheckbox.checked = false;
            usernameField.readOnly = false;
            emailField.readOnly = false;
          } else {
            isBoostBotCheckbox.checked = true;
          }
        }

        form.setAttribute("action", "/community_admins");
        form.setAttribute("method", "post");
        emailField.readOnly = false;

        // Remove the _method field if it exists
        let methodInput = document.querySelector('input[name="_method"]');
        if (methodInput) methodInput.remove();

        document.querySelector(".modal-title").innerHTML = "Create admin";
      }
    });
  });
});
