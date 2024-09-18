import $ from 'jquery';
import DataTable from 'datatables.net-bs4';
import 'datatables.net-select-bs4';
import { sendPatchRequest } from 'custom_js/api_util';

const COLUMNS = {
  keyword_filter_group_list: [
    { data: 'name' },
    { data: 'server_setting' },
    { data: 'is_active' },
    {
      data: 'keyword_filters',
      render: function(data, type, row) {
        if (data && Array.isArray(data)) {
          return '<ul>' + data.map(function(filter) {
            return `<li>${filter.keyword}</li>`;
          }).join('') + '</ul>';
        } else {
          return '';
        }
      }
    }
  ]
};

const COLUMN_DEFS = {};

jQuery(function() {
  $('#datatable').css('width', '100%');

  let url = $('#datatable').data('url');
  let type = $('#datatable').data('type');
  let selectable = $('#datatable').data('selectable');
  let isCustom = $('#datatable').data('is-custom');

  if (isCustom) {
    COLUMNS.keyword_filter_group_list.push({
      data: 'keyword_filters',
      render: function(data, type, row) {
        if (data && Array.isArray(data)) {
          return '<ul>' + data.map(function(filter) {
            const editUrl = filter.edit_url;
            const deleteUrl = filter.delete_url;
            const editClass = filter.is_custom_group ? '' : 'disabled';
            const deleteClass = filter.is_custom_group ? '' : 'disabled';
            const actions = filter.is_custom_group ? `<li>
                      <a href="${editUrl}" class="edit-icon ${editClass}" title="Edit"><i class="fas fa-edit"></i></a>
                      <a href="${deleteUrl}" class="delete-icon ${deleteClass}" title="Delete" data-confirm="Are you sure?" data-method="delete"><i class="fas fa-trash"></i></a>
                    </li>` : '';
            return actions;
          }).join('') + '</ul>';
        } else {
          return '';
        }
      }
    });
  }

  let options = {
    destroy: false,
    paging: false,
    searching: false,
    serverSide: true,
    processing: true,
    lengthMenu: false,
    info: false,
    ajax: {
      type: "GET",
      url: url,
      dataType: "json",
      data: (d) => {
        let selected = localStorage.getItem('selected');
        if (selected == 'all') {
          d.selected = selected;
        } else {
          d.selected = JSON.parse(selected) || [];
        }

        let unselected = localStorage.getItem('unselected');
        if (unselected) {
          d.unselected = JSON.parse(unselected) || [];
        }
      },
    },
    columns: COLUMNS[type],
    columnDefs: COLUMN_DEFS[type],
  };

  if (selectable == 'multi') {
    options['select'] = {
      style: 'multi',
      selector: 'td:first-child'
    };
  }

  var table = $('#datatable').DataTable(options);

  // Handling multiple selection
  var table_without_option = $('#datatable').DataTable();

  table_without_option.on('draw', function() {
    $('tr').each(function() {
      var row = $(this);
      var checkbox = row.find('.checkbox');

      if (checkbox.is(':checked')) {
        row.addClass('selected');
      } else {
        row.removeClass('selected');
      }
    });
  });

  // Handling modal close event
  $('#keyFilterModal').on('hidden.bs.modal', function () {
    var form = $(this).find('form')[0];
    if (form) {
      form.reset();
    }

    $(this).find('.error-message').remove();
    $(this).find('.is-invalid').removeClass('is-invalid');

    handleNestedFields($(this).find('.nested-fields'));
    $('#keyword_filter_group_name').val(null).trigger('change');
  });

  function handleNestedFields(nestedFieldsContainer) {
    var nestedFields = nestedFieldsContainer.parent().children('.nested-fields');

    if (nestedFields.length > 1) {
      nestedFields.slice(1).remove();
    }

    nestedFields.find('input[type="text"]').val('');
  }

  window.handleEditClick = function(element) {
    var maxCharsValue = element.getAttribute('data-optional-value');
    var maxCharsInput = document.getElementById('max_chars_value');
    maxCharsInput.value = maxCharsValue || '';
  };

  function updateSetting(checkbox) {
    const settingId = checkbox.getAttribute('data-setting-id');
    const isChecked = checkbox.checked;
    const data = { server_setting: { value: isChecked } };

    sendPatchRequest(`/server_settings/${settingId}`, data);
  }

  function showModalIfNeeded(checkbox) {
    const settingName = checkbox.getAttribute('data-setting-name').toLowerCase();

    if (settingName === 'long posts and markdown' && checkbox.checked) {
      const optionalValue = checkbox.getAttribute('data-optional-value');
      const maxCharsInput = document.getElementById('max_chars_value');
      maxCharsInput.value = optionalValue || '';

      $('#maxCharsModal').modal('show');
    }
  }

  const settingSwitches = document.querySelectorAll('.setting-input');
  settingSwitches.forEach(function(switchElement) {
    switchElement.addEventListener('change', function(event) {
      const checkbox = event.target;
      updateSetting(checkbox);
      showModalIfNeeded(checkbox);
    });
  });

  const saveMaxCharsButton = document.getElementById('saveMaxChars');
  if (saveMaxCharsButton) {
    saveMaxCharsButton.addEventListener('click', function() {
      const maxCharsInput = document.getElementById('max_chars_value');
      const newValue = maxCharsInput ? maxCharsInput.value : '';

      const settingElement = Array.from(document.querySelectorAll('.setting-input'))
        .find(el => el.getAttribute('data-setting-name').toLowerCase() === 'long posts and markdown');

      if (settingElement) {
        const settingId = settingElement.getAttribute('data-setting-id');
        const data = { server_setting: { optional_value: newValue } };
        sendPatchRequest(`/server_settings/${settingId}`, data)
          .then(() => {
            location.reload();
          });
      }
    });
  }

  $('#CommunityFilterModal').on('show.bs.modal', function(event) {
    var button = $(event.relatedTarget);
    var keywordId = button.data('id');
    var keyword = button.data('keyword');
    var isFilterHashtag = button.data('isFilterHashtag');

    var modal = $(this);
    var form = modal.find('form');
    var modalTitle = modal.find('.modal-title');
    var keywordInput = $('#keyword-input');
    var isFilterHashtagInput = $('#is_filter_hashtag-input');

    if (keywordId) {
      // Editing keyword filter
      modalTitle.text('Edit keyword filtering');
      form.find('input[name="_method"]').val('patch');
      form.attr('action', `/community_filter_keywords/${keywordId}`);
      keywordInput.val(keyword);
      isFilterHashtagInput.prop('checked', isFilterHashtag == true);
    } else {
      // Adding new keyword filter
      modalTitle.text('Add keyword filtering');
      form.attr('action', '/community_filter_keywords');
      form.find('input[name="_method"]').val('post');
      keywordInput.val('');
      isFilterHashtagInput.prop('checked', false);
    }
    var csrfToken = $('meta[name="csrf-token"]').attr('content');
    form.append(`<input type="hidden" name="authenticity_token" value="${csrfToken}">`);
  });

  $(document).on('click', '.edit-admin-link', function (e) {
    e.preventDefault();

    var communityId = $(this).data('community-id');
    var adminId = $(this).data('admin-id');

    var url = `/communities/${communityId}/step2?admin_id=${adminId}`;

    $.ajax({
      url: url,
      type: 'GET',
      dataType: 'json',
      success: function (data) {
        $('#edit_admin_admin_id').val(data.admin_id);
        $('#edit_admin_display_name').val(data.display_name);
        $('#edit_admin_username').val(data.username);
        $('#editAdminModal').modal('show');
      },
      error: function () {
        alert('An error occurred while loading the admin details.');
      }
    });
  });

  $('#editHashtagModal').on('show.bs.modal', function (event) {
    var button = $(event.relatedTarget);
    var hashtagId = button.data('id');
    var hashtag = button.data('hashtag');

    var modal = $(this);
    modal.find('#edit_hashtag_id').val(hashtagId);
    modal.find('#edit_hashtag_input').val('#' + hashtag);
  });

});
