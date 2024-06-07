import $ from 'jquery'

import DataTable from 'datatables.net-bs4'
import 'datatables.net-select-bs4'

const COLUMNS = {
  keyword_filter_group_list: [
    { data: 'name' },
    { data: 'server_setting' },
    { data: 'is_active' },
    {
      data: 'keyword_filters',
      render: function(data, type, row) {
        if (data && Array.isArray(data)) {
          return '<ol>' + data.map(function(filter) {
            return `<li>${filter.keyword}</li>`;
          }).join('') + '</ol>';
        } else {
          return '';
        }
      }
    }
  ]
}

const COLUMN_DEFS = {
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
    lengthMenu: false,
    info: false,
    ajax: {
      type: "GET",
      url: url,
      dataType: "json",
      data: (d) => {

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
  // multiple selection
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
})
