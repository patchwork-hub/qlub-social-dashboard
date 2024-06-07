document.addEventListener('DOMContentLoaded', function() {
  function setModalDetails(title, id) {
    $('.modal-title').text(title);
    const serverSettingIdInput = $('#serverSettingId');
    serverSettingIdInput.val(id);
  }

  $('a[data-toggle="modal"]').click(function (event) {
    event.preventDefault();

    const title = $(this).attr('title');
    const id = $(this).data('id');

    setModalDetails(title, id);
  });
});
