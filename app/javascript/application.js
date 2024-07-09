import 'bootstrap';
import 'admin-lte';
import "@nathanvda/cocoon";
import 'lib/datatable';
import 'custom_js/api_util';
import 'custom_js/modal_handler';
import 'custom_js/keyword_groups';
import 'custom_js/header';

import {far} from '@fortawesome/free-regular-svg-icons'
import {fas} from '@fortawesome/free-solid-svg-icons'
import {fab} from '@fortawesome/free-brands-svg-icons'
import {library} from '@fortawesome/fontawesome-svg-core'
import '@fortawesome/fontawesome-free'
library.add(far, fas, fab)

import Rails from '@rails/ujs'
Rails.start()

localStorage.setItem('selected', null);
localStorage.setItem('unselected', null);

$(document).ready(function() {

  $('.select2').select2({
    dropdownParent: $('#keyFilterModal'),
    tags: true,
    placeholder: 'Select an option',
    allowClear: true,
    theme: 'bootstrap'
  });

  document.addEventListener('DOMContentLoaded', function() {
    const keywordFilterForm = document.querySelector('#keyFilterModal form');
    if (keywordFilterForm) {
      keywordFilterForm.addEventListener('submit', function(event) {
        event.preventDefault();
        const formData = new FormData(keywordFilterForm);
        const url = keywordFilterForm.action;
        const submitButton = document.querySelector('.submit-btn');

        document.querySelectorAll('.error-message').forEach(el => el.remove());
        document.querySelectorAll('.form-control').forEach(el => el.classList.remove('is-invalid'));

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
            if (submitButton) {
              submitButton.disabled = false;
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

    const nestedAttributeContainer = document.querySelector('.nested-fields');

    if (nestedAttributeContainer && nestedAttributeContainer.children.length === 0) {
      const addNewLink = nestedAttributeContainer.querySelector('.add_fields');
      if (addNewLink) {
        addNewLink.click();
      }
    }
  });

  const collapseToggles = document.querySelectorAll(".collapse-toggle");

  collapseToggles.forEach(function(toggle) {
    toggle.addEventListener("click", function() {
      const arrowDown = toggle.querySelector(".icon-arrow-down");
      const arrowUp = toggle.querySelector(".icon-arrow-up");

      if (toggle.getAttribute("aria-expanded") === "true") {
        arrowDown.style.display = "inline-block";
        arrowUp.style.display = "none";
      } else {
        arrowDown.style.display = "none";
        arrowUp.style.display = "inline-block";
      }
    });
  });
})

const togglePassword = (e) => {
	let input = document.querySelector('input#password');

	if (input.type == 'password') {
		e.setAttribute('class', 'svg-inline--fa fa-eye');
		input.type = 'text';
	} else {
		e.setAttribute('class', 'svg-inline--fa fa-eye-slash');
		input.type = 'password';
	}

}

window.togglePassword = togglePassword;
