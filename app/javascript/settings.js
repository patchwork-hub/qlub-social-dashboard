import { sendPatchRequest } from './api_util';

document.addEventListener('DOMContentLoaded', function() {
  function updateSetting(checkbox) {
    const settingId = checkbox.getAttribute('data-setting-id');
    const isChecked = checkbox.checked;
    const data = { server_setting: { value: isChecked } };

    sendPatchRequest(`/server_settings/${settingId}`, data)
      .then(response => {
        console.log('Setting updated successfully:', response);
      })
      .catch(error => {
        console.error('Error updating setting:', error);
        $('#keyFilterModal').modal('show');
      });
  }

  const settingSwitches = document.querySelectorAll('.setting-input');
  settingSwitches.forEach(function(switchElement) {
    switchElement.addEventListener('change', function(event) {
      updateSetting(event.target);
    });
  });

  const keywordFilterForm = document.querySelector('#keyFilterModal form');
  if (keywordFilterForm) {
    const submitButton = document.querySelector('.submit-btn');

    keywordFilterForm.addEventListener('submit', function(event) {
      event.preventDefault();
      const formData = new FormData(keywordFilterForm);
      const url = keywordFilterForm.action;

      fetch(url, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        body: formData
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          location.reload();
        } else {
          // Clear previous errors
          document.querySelectorAll('.error-message').forEach(el => el.remove());
          document.querySelectorAll('.form-control').forEach(el => el.classList.remove('is-invalid'));

          // Ensure submit button exists before modifying its state
          if (submitButton) {
            submitButton.disabled = false; // Re-enable the button
          }

          // Handle errors
          const errors = data.error.split(', ');
          errors.forEach(error => {
            const errorMessage = document.createElement('small');
            errorMessage.className = 'error-message text-danger';
            errorMessage.textContent = error;

            if (error.includes('Name')) {
              const nameInput = document.querySelector('input[name="keyword_filter_group[name]"]');
              if (nameInput) {
                nameInput.classList.add('is-invalid');
                nameInput.after(errorMessage);
              }
            } else if (error.includes('Keyword')) {
              document.querySelectorAll('input[name^="keyword_filter_group[keyword_filters_attributes]"][name$="[keyword]"]').forEach(input => {
                if (input) {
                  input.classList.add('is-invalid');
                  input.after(errorMessage);
                }
              });
            }
          });
        }
      })
      .catch(error => {
        console.error('Error submitting form:', error);
        const errorMessage = document.createElement('small');
        errorMessage.className = 'error-message text-danger';
        errorMessage.textContent = 'An unexpected error occurred. Please try again.';
        const modalBody = document.querySelector('#keyFilterModal .modal-body');
        if (modalBody) {
          modalBody.prepend(errorMessage);
        }
      });
    });
  }
});
