import 'bootstrap';
import 'admin-lte';
import "@nathanvda/cocoon";
import 'lib/datatable';
import 'custom_js/api_util';
import 'custom_js/modal_handler';
import 'custom_js/settings';
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

  $('#datatable tbody').on('click', '.selectable-checkbox', function(e) {
    e.stopPropagation();

    var checkbox = $(this).find('input[type=checkbox]');
    var _id = checkbox.val();

    var unselected = JSON.parse(localStorage.getItem('unselected')) || [];
    var selected = localStorage.getItem('selected');

    if (selected !== 'all') {
      selected = JSON.parse(selected) || [];
    }

    var tr = $(this).closest('tr');
    if (!tr.hasClass('selected')) {
      checkbox.prop('checked', true);
      tr.addClass('selected');
      if (selected !== 'all') {
        selected.push(_id);
      }
      if (selected === 'all') {
        unselected = unselected.filter(function(id) {
          return id !== _id;
        });
      }
    } else {
      checkbox.prop('checked', false);
      tr.removeClass('selected');
      if (selected !== 'all') {
        selected = selected.filter(function(id) {
          return id !== _id;
        });
      }
      if (selected === 'all') {
        unselected.push(_id);
      }
    }

    if (selected === 'all') {
      if (unselected.length > 0) {
        $('#select_all').prop('checked', false);
        $('#select_all').prop('indeterminate', true);
      } else {
        $('#select_all').prop('checked', true);
        $('#select_all').prop('indeterminate', false);
      }
    }

    addParams(selected, unselected);

    if (selected !== 'all') {
      selected = JSON.stringify(selected);
    }
    unselected = JSON.stringify(unselected);

    if (selected !== 'all') {
      localStorage.setItem('selected', selected);
    }
    localStorage.setItem('unselected', unselected);
  });


  $('#select_all').on('change', function(e) {
    localStorage.setItem('unselected', null);

    if ($(this).is(':checked')) {
      $('tbody tr').addClass('selected');
      $("input[type='checkbox']").prop('checked', true);
      addParams('all');
      localStorage.setItem('selected', 'all');
    } else {
      $('tbody tr').removeClass('selected');
      $("input[type='checkbox']").prop('checked', false)
      addParams();
      localStorage.setItem('selected', null);
    }
  })

  $('input[type="search"]').on('change', function(e) {
    addParams();
  })
  // end of multiple selection

  $(document).on('change', '.deprecate-version-checkbox', function(e) {
    e.preventDefault();
    var id = $(e.currentTarget).val();
    $.ajax({
      url: `/history/${id}/deprecate`,
      method: 'PUT',
      dataType: 'json',
      success: function(response) {
        console.log('Update successful!', response);
      },
      error: function(xhr, status, error) {
        console.error('Update failed:', error);
      }
    });
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
})

const addParams = (selected = null, unselected = null) => {
  const btn = $('#export-selected');
  const q = $('input[type="search"]').val();
  let url = new URL($(btn).attr('href'));
  const params = new URLSearchParams(url.search);

  params.delete('selected');
  params.delete('unselected');
  params.delete('q');

  if (selected !== null) {
    params.set('selected', selected);
  }

  if (unselected !== null) {
    params.set('unselected', unselected);
  }

  if (q !== null && q.trim() !== '') {
    params.set('q', q);
  }

  url.search = params.toString();
  $(btn).attr('href', url.href);
};


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
