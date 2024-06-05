import { sendPatchRequest } from './api_util';

document.addEventListener('DOMContentLoaded', function() {
  function updateKeyword(groupId, isChecked) {
    const data = {
      keyword_filter_group: {
        is_active: isChecked
      }
    };

    sendPatchRequest(`/keyword_filter_groups/${groupId}`, data);
  }

  const keywordSwitches = document.querySelectorAll('.keyword-input');
  keywordSwitches.forEach(function(switchElement) {
    switchElement.addEventListener('change', function(event) {
      const groupId = event.target.getAttribute('data-group-id');
      const isChecked = event.target.checked;
      updateKeyword(groupId, isChecked);
    });
  });
});
