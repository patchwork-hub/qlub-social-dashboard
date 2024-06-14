document.addEventListener('DOMContentLoaded', function() {
  function setModalDetails(title, id) {
    $('.modal-title').text(title);
    const serverSettingIdInput = $('#serverSettingId');
    serverSettingIdInput.val(id);
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
      error: function(xhr, status, error) {
        console.error('Error fetching data:', error);
      }
    });
  }

  $('a[data-toggle="modal"]').click(function (event) {
    event.preventDefault();

    const title = $(this).attr('title');
    const id = $(this).data('id');

    setModalDetails(title, id);
  });
});
