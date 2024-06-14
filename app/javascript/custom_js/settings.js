import { sendPatchRequest } from 'custom_js/api_util';

document.addEventListener('DOMContentLoaded', function() {
  function updateSetting(checkbox) {
    const settingId = checkbox.getAttribute('data-setting-id');
    const isChecked = checkbox.checked;
    const data = { server_setting: { value: isChecked } };

    sendPatchRequest(`/server_settings/${settingId}`, data);
  }

  const settingSwitches = document.querySelectorAll('.setting-input');
  settingSwitches.forEach(function(switchElement) {
    switchElement.addEventListener('change', function(event) {
      updateSetting(event.target);
    });
  });

  // const settingInputs = document.querySelectorAll('.setting-input');

  // settingInputs.forEach(input => {
  //   input.addEventListener('change', function() {
  //     const settingName = this.getAttribute('data-setting-name');

  //     if (settingName === 'Content filters' || settingName === 'Spam filters') {

  //       setTimeout(() => {
  //         window.location.reload();
  //       }, 1000);
  //     }
  //   });
  // });
});
