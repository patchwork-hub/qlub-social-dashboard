import $ from 'jquery'
import 'bootstrap'
import 'admin-lte'
import 'lib/datatable'

import DataTable from 'datatables.net-bs4'
import 'datatables.net-select-bs4'

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

  // multiple selection
  var table = $('#datatable').DataTable();

  table.on('draw', function() {
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

  //calculating server setting position
  var parentSelect = document.getElementById('parentSelect');
  var positionField = document.getElementById('positionField');
  var originalPosition = positionField ? positionField.value : null; 
  var originalParentId = parentSelect ? parentSelect.value : null; 

  if (parentSelect && positionField) {
    parentSelect.addEventListener('change', function() {
      var parentId = this.value;
      if (parentId) {
        $.ajax({
          url: '/get_child_count',
          type: 'GET',
          data: { parentId: parentId },
          success: function(response) {
            var childCount = response.childCount;
            positionField.value = parentId === originalParentId ? originalPosition : childCount + 1;
          },
          error: function(xhr, status, error) {
            console.error('Failed to fetch child count:', error);
          }
        });
      } else {
        positionField.value = '';
      }
    });
  }
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
