
function setModalDetails(title, id, label) {
  // Set the modal title
  $('.modal-title').text(title);
  // Set the hidden input for server setting ID
  const serverSettingIdInput = $('#serverSettingId');
  serverSettingIdInput.val(id);
  // Set the name label text
  $('label[for="keyword_filter_group_name"]').text(label);
  // Fetch and populate existing data for the select element
  fetchExistingData(id);
}

function fetchExistingData(serverSettingId) {
  $.ajax({
    url: '/server_settings/group_data',
    data: { server_setting_id: serverSettingId },
    success: function(data) {
      const selectElement = $('#keyword_filter_group_name');
      selectElement.empty();
      data.forEach(function(item) {
        selectElement.append(new Option(item, item));
      });
    },
    error: function(error) {
      console.error('Error fetching data:', error);
    }
  });
}

$('a[data-toggle="modal"]').click(function (event) {
  event.preventDefault();
  const title = $(this).attr('title');
  const id = $(this).data('id');
  const label = $(this).data('label');
  setModalDetails(title, id, label);
});
