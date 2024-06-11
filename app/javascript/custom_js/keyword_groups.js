import { sendPatchRequest } from 'custom_js/api_util';

document.addEventListener('DOMContentLoaded', function() {
  function updateKeywordGroup(groupId, isChecked) {
    const data = {
      keyword_filter_group: {
        is_active: isChecked
      }
    };

    sendPatchRequest(`/keyword_filter_groups/${groupId}/update_is_active`, data);
  }

  const keywordSwitches = document.querySelectorAll('.keyword-group-input');
  keywordSwitches.forEach(function(switchElement) {
    switchElement.addEventListener('change', function(event) {
      const groupId = event.target.getAttribute('data-group-id');
      const isChecked = event.target.checked;
      updateKeywordGroup(groupId, isChecked);
    });
  });
});
