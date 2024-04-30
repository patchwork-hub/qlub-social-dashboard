import $ from 'jquery'

import DataTable from 'datatables.net-bs4'
import 'datatables.net-select-bs4'

const COLUMNS = {
  community: [
    {data: 'name'},
    {data: 'actions', orderable: false}
  ],
  community_detail: [
    {data: 'display_name'},
    {data: 'username'},
    {data: 'email'},
    {data: 'role'},
    {data: 'actions', orderable: false}
  ],
  report_list: [
    {data: 'owner_name'},
    {data: 'owner_username'},
    {data: 'reporter_name'},
    {data: 'reporter_username'},
    {data: 'text'},
    {data: 'actions', orderable: false}
  ],
  wait_list: [
    {data: 'email'},
    {data: 'role'},
    {data: 'cr_name'},
    {data: 'created_at'},
    {data: 'actions', orderable: false}
  ],
  invitation_code: [
    {data: 'id'},
    {data: 'invitation_code'},
    {data: 'role'},
    {data: 'is_invitation_code_used'},
    {data: 'username'},
  ],
  account: [
    {data: 'id'},
    {data: 'email'},
    {data: 'username'},
    {data: 'phone'},
    {data: 'registered_at'},
    {data: 'user_role'},
    {data: 'community_name'},
    {data: 'actions', orderable: false}
  ],
  version_list: [
    {data: 'version_name'},
    {data: 'for_android', orderable: false},
    {data: 'android_deprecated', orderable: false},
    {data: 'for_ios', orderable: false},
    {data: 'ios_deprecated', orderable: false},
    {data: 'apk_download_link', orderable: false}
  ],
  hashtag_list: [
    {data: 'hashtag'},
    {data: 'actions', orderable: false}
  ],
  filter_list: [
    {data: 'keyword'},
    {data: 'is_filter_hashtag'},
    {data: 'actions', orderable: false}
  ],
  timelines_status_list: [
    { data: 'name' },
    { data: 'is_operational' },
    { data: 'created_at' },
  ],
  server_setting_list: [
    { data: 'name' },
    { data: 'settings' }
  ]
}

const COLUMN_DEFS = {
  account: [
    {className: 'selectable-checkbox', orderable: false, targets: 0},
    {className: "dt-nowrap", targets: 5}
  ],
  invitation_code: [
    {className: 'selectable-checkbox', orderable: false, targets: 0}
  ],
  server_setting_list: [
    {
      className: 'selectable-checkbox',
      orderable: false,
      targets: 0
    },
    {
      className: "dt-wrap",
      targets: 1,
      render: function(data, type, row) {
        let settingsHtml = '';
        row.settings.forEach(function(setting) {
          settingsHtml += `
          <div class="chip">
            ${setting.name}
            <label class="form-check-label switch" for="${setting.id}">
              <input class="form-check-input switch-input" type="checkbox" id="${setting.id}" ${setting.is_operational ? 'checked' : ''} data-setting-id="${setting.id}">
              <span class="switch-slider round"></span>
            </label>
          </div>`;
        });
        return settingsHtml;
      }
    }
  ]  
}

jQuery(function() {

  $('#datatable').css('width', '100%');

  let entries = [ 10, 25, 50, 100, 1000, 10000, 100000 ]

 	let url        = $('#datatable').data('url')
  let type       = $('#datatable').data('type')
  let selectable = $('#datatable').data('selectable')
  
  let options = {
    destroy:    true,
    paging:     true,
    searching:  true,
    serverSide: true,
    processing: true,
    lengthMenu: entries,
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
