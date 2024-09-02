import 'bootstrap';
import 'admin-lte';
import "@nathanvda/cocoon";
import 'lib/datatable';
import 'custom_js/api_util';
import 'custom_js/modal_handler';
import 'custom_js/keyword_groups';
import 'custom_js/community_contributor_data_table';
import 'custom_js/follow_unfollow';
import 'custom_js/header';
import 'custom_js/followed_contributors_table';

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

import ClassicEditor from '@ckeditor/ckeditor5-build-classic';

$(document).ready(function() {
  document.querySelectorAll('.ckeditor').forEach((element) => {
    ClassicEditor
      .create(element)
      .catch(error => {
        console.error(error);
      });
  });

  const element = document.getElementById('community_bio');
  if (element) {
    ClassicEditor
      .create(element, {
        toolbar: ['bold', 'italic', 'link']
      })
      .catch(error => {
        console.error(error);
      });
  }

  $('.select2').select2({
    dropdownParent: $('#keyFilterModal'),
    tags: true,
    placeholder: 'Select an option',
    allowClear: true,
    theme: 'bootstrap'
  });

  const keywordFilterForm = document.querySelector('#keyFilterModal form');

  if (keywordFilterForm) {
    keywordFilterForm.addEventListener('submit', function(event) {
      event.preventDefault();
      const formData = new FormData(keywordFilterForm);
      const url = keywordFilterForm.action;
      const submitButton = document.querySelector('.submit-btn');

      clearPreviousErrors();

      if (!validateKeywords()) {
        displayErrorMessage('Keyword cannot be blank.');
        enableSubmitButton(submitButton);
        return;
      }

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
          enableSubmitButton(submitButton);
          handleKeywordFilterGroupErrors(data.error);
        }
      })
      .catch(error => {
        console.error('Error submitting form:', error);
        displayErrorMessage('An unexpected error occurred. Please try again.');
        enableSubmitButton(submitButton);
      });
    });
  }

  function clearPreviousErrors() {
    document.querySelectorAll('.error-message').forEach(el => el.remove());
    document.querySelectorAll('.form-control').forEach(el => el.classList.remove('is-invalid'));
  }

  function validateKeywords() {
    let isValid = true;
    document.querySelectorAll('input[name^="keyword_filter_group[keyword_filters_attributes]"][name$="[keyword]"]').forEach(input => {
      if (!input.value.trim()) {
        input.classList.add('is-invalid');
        isValid = false;
      }
    });
    return isValid;
  }

  function displayErrorMessage(message) {
    const errorMessage = document.createElement('small');
    errorMessage.className = 'error-message text-danger';
    errorMessage.textContent = message;
    document.querySelectorAll('input[name^="keyword_filter_group[keyword_filters_attributes]"][name$="[keyword]"]').forEach(input => {
      if (input.classList.contains('is-invalid')) {
        input.after(errorMessage.cloneNode(true));
      }
    });
  }

  function enableSubmitButton(button) {
    if (button) {
      button.disabled = false;
      button.removeAttribute('data-disable-with');
    }
  }

  function handleKeywordFilterGroupErrors(errorMessage) {
    const errors = errorMessage.split(', ');
    errors.forEach(error => {
      const errorElement = document.createElement('small');
      errorElement.className = 'error-message text-danger';
      errorElement.textContent = error;

      if (error.includes('Name')) {
        const nameInput = document.querySelector('input[name="keyword_filter_group[name]"]');
        if (nameInput) {
          nameInput.classList.add('is-invalid');
          nameInput.after(errorElement);
        }
      } else if (error.includes('Keyword')) {
        document.querySelectorAll('input[name^="keyword_filter_group[keyword_filters_attributes]"][name$="[keyword]"]').forEach(input => {
          if (input) {
            input.classList.add('is-invalid');
            input.after(errorElement);
          }
        });
      }
    });
  }

  const nestedAttributeContainer = document.querySelector('.nested-fields');

  if (nestedAttributeContainer && nestedAttributeContainer.children.length === 0) {
    const addNewLink = nestedAttributeContainer.querySelector('.add_fields');
    if (addNewLink) {
      addNewLink.click();
    }
  }

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
  
  // Function to search for contributors
  function searchContributors(query) {
    if (query.length === 0) {
      clearSearchResults();
      return;
    }

    showLoadingSpinner();
  
    fetch(`/communities/search_contributor?query=${encodeURIComponent(query)}`)
      .then(response => response.json())
      .then(data => {
        hideLoadingSpinner();
        displaySearchResults(data.accounts);
      })
      .catch(error => {
        hideLoadingSpinner();
        console.log('Error fetching search results:', error);
      });
  }

  // Function to show the loading spinner and disable background
  function showLoadingSpinner() {
    document.getElementById('disabled-overlay').style.display = 'flex';
  }

  // Function to hide the loading spinner and enable background
  function hideLoadingSpinner() {
    document.getElementById('disabled-overlay').style.display = 'none';
  }

  // Function to display search results in the modal
  function displaySearchResults(accounts) {
    const resultsContainer = document.getElementById('search-results');
    resultsContainer.innerHTML = '';

    if (accounts.length === 0) {
      resultsContainer.innerHTML = '<p>No results found.</p>';
      return;
    }

    accounts.forEach(account => {
      const resultItem = document.createElement('div');
      resultItem.className = 'list-group-item align-items-center';
      resultItem.innerHTML = `
        <div class="profile-info row">
          <div class="col-auto">
            <img src="${account.avatar}" alt="${account.username}" class="rounded-circle mr-2" style="width: 70px; height: 70px;">
          </div>
          <div class="col">
            <p class="mb-0">${account.display_name || account.username}</p>
            <small class="text-muted">@${account.acct}</small>
            ${account.note ? `<small class="small">${account.note}</small>` : ''}
          </div>
          <div class="col-auto ml-5 pl-5 mt-5">
            <button class="btn btn-outline-secondary mute-button" data-account-id="${account.id}" style="float: right;">
              ${isMuted(account.id) ? 'Unmute' : 'Mute'}
            </button>
          </div>
        </div>
      `;

      resultsContainer.appendChild(resultItem);
    });

    // Add event listeners for mute buttons
    document.querySelectorAll('.mute-button').forEach(button => {
      button.addEventListener('click', function() {
        const accountId = this.dataset.accountId;
        toggleMute(accountId); // Define this function to handle the mute/unmute action
      });
    });
  }

  // Function to clear the search results
  function clearSearchResults() {
    const resultsContainer = document.getElementById('search-results');
    resultsContainer.innerHTML = '';
  }

  // Function to check is Mute or not
  function isMuted(accountId) {
    return false;
  }

  // Event listener for the search box
  document.getElementById('search-input').addEventListener('keydown', function(event) {
    if (event.key === 'Enter' || event.keyCode === 13) {
      searchContributors(this.value);
    }
  });

})

const togglePassword = (e) => {
	let input = document.querySelector('input#password');

	if (input.type == 'password') {
		e.setAttribute('class', 'svg-inline--fa fa-eye red');
		input.type = 'text';
	} else {
		e.setAttribute('class', 'svg-inline--fa fa-eye-slash red');
		input.type = 'password';
	}

}

window.togglePassword = togglePassword;
