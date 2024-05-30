import $ from 'jquery'

import DataTable from 'datatables.net-bs4'
import 'datatables.net-select-bs4'

const COLUMNS = {
  server_setting_list: [
    { data: 'name' }
  ],
  keyword_filter_list: [
    {data: 'server_setting_id'},
    {data: 'keyword'},
    {data: 'is_active'},
    {data: 'filter_type'}
  ]
}

const COLUMN_DEFS = {
  server_setting_list: [
    {
      targets: 0,
      render: function(data, type, row) {
        let settingsHtml = `<div class="d-flex justify-content-between">
                              <div>${row.name}</div>`;
        if (row.settings && row.settings.length) {
          row.settings.forEach(setting => {
            settingsHtml += `
            <div style="padding-left: 20px;">
              <label class="form-check-label switch" for="${setting.id}">
                <input class="form-check-input switch-input" type="checkbox" id="${setting.id}" ${setting.is_operational ? 'checked' : ''} data-setting-id="${setting.id}">
                <span class="switch-slider round"></span>
              </label>
              ${setting.name}
            </div>
            </div>`;
          });
        }
        return settingsHtml;
      }
    }
  ]
}

jQuery(function() {

  $('#datatable').css('width', '100%');

 	let url        = $('#datatable').data('url')
  let type       = $('#datatable').data('type')
  let selectable = $('#datatable').data('selectable')

  let options = {
    destroy:    false,
    paging:     false,
    searching:  false,
    serverSide: true,
    processing: true,
    lengthChange: false,
    info: false,
    ajax: {
      type: "GET",
      url: url,
      dataType: "json",
      data: (d) => {
        let community_id = $('#community_id').val();
        if (community_id) {
          d.community_id = community_id;
        }

        let selected = localStorage.getItem('selected');
        if (selected == 'all'){
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
  }

  if (selectable == 'multi') {
    options['select'] = {
      style: 'multi',
      selector: 'td:first-child'
    }
  }

  var table = $('#datatable').DataTable(options);

  $('#datatable').on('change', '.switch-input', function(event) {
    updateSetting(event.target);
  });
});

function updateSetting(checkbox) {
  const settingId = checkbox.getAttribute('data-setting-id');
  const isChecked = checkbox.checked;

  $.ajax({
    type: 'PATCH',
    url: '/server_settings/' + settingId,
    beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
    data: { server_setting: { value: isChecked } },
    success: function(response) {
      console.log('Setting updated successfully');
    },
    error: function(xhr, status, error) {
      console.error('Failed to update setting:', error);
    }
  });
}
