import { sendPatchRequest } from './api_util';

document.addEventListener('DOMContentLoaded', function() {
  function updateKeyword(checkbox) {
    const keywordId = checkbox.getAttribute('data-keyword-id');
    const filterType = checkbox.getAttribute('data-filter-type');
    const serverSettingId = checkbox.getAttribute('data-server-setting-id');
    const isChecked = checkbox.checked;
    const data = {
      keyword_filter: {
        is_active: isChecked,
        filter_type: filterType,
        server_setting_id: serverSettingId
      }
    };

    sendPatchRequest(`/keyword_filters/${keywordId}`, data);
  }

  const keywordSwitches = document.querySelectorAll('.keyword-input');
  keywordSwitches.forEach(function(switchElement) {
    switchElement.addEventListener('change', function(event) {
      updateKeyword(event.target);
    });
  });
});
