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

  $(document).on('ajax:complete', function () {
    $('a[data-toggle="modal"]').off('click').on('click', function (event) {
      event.preventDefault();

      const title = $(this).attr('title');
      const id = $(this).data('id');

      setModalDetails(title, id);
    });
  });

  // Modal reset on close
//   var keyFilterModal = document.getElementById('keyFilterModal');
//   keyFilterModal.addEventListener('hidden.bs.modal', function() {
//     var form = $(this).find('form')[0];
//     if (form) {
//       form.reset();
//     }
//     $(this).find('.error-message').remove();
//     $(this).find('.is-invalid').removeClass('is-invalid');

//     $(this).find('.nested-fields').remove_nested_fields();
//     $(this).find('.select2').val(null).trigger('change');

//     console.log("BUTTON_CLOSE");
//   });
});
