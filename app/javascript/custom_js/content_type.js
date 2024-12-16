document.addEventListener("DOMContentLoaded", () => {
  const elements = {
    contributorOr: document.getElementById("contributor_or"),
    contributorAnd: document.getElementById("contributor_and"),
    customChannelSwitch: document.getElementById("custom_channel_switch"),
    broadcastChannelSwitch: document.getElementById("broadcast_channel_switch"),
    groupChannelSwitch: document.getElementById("group_channel_switch"),
    nestedOptions: document.getElementById("nested-options"),
    hashtagsSection: document.getElementById("hashtags-section"),
    contributorsSection: document.getElementById("contributors-section"),
    keywordFilterSection: document.getElementById("keyword-filters-section"),
    communityId: document.getElementById("community_id"),
  };

  const createOrUpdateContentType = (channelType) => {
    const communityId = elements.communityId.value;
    const url = `/content_types`;
    const method = "POST";

    fetch(url, {
      method: method,
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").getAttribute("content"),
      },
      body: JSON.stringify({
        content_type: {
          channel_type: channelType,
          patchwork_community_id: communityId,
          custom_condition: elements.contributorOr.checked ? "or_condition" : elements.contributorAnd.checked ? "and_condition" : null,
        }
      })
    }).then(response => {
      if (response.ok) {
        window.location.reload();
        console.log("Content type created or updated successfully");
      } else {
        console.error("Error creating or updating content type");
      }
    });
  };

  const initializeFormState = () => {
    if (elements.customChannelSwitch) {
      const shouldShowNestedOptions = elements.customChannelSwitch.checked;
      elements.nestedOptions.classList.toggle("show", shouldShowNestedOptions);

      toggleVisibility();
    }
  };

  const toggleVisibility = () => {
    const { contributorOr, contributorAnd, hashtagsSection, contributorsSection, keywordFilterSection } = elements;
    if (contributorOr && contributorAnd) {
      const isAnyChecked = contributorOr.checked || contributorAnd.checked;
      hashtagsSection.style.display = isAnyChecked ? "block" : "none";
      contributorsSection.style.display = isAnyChecked ? "block" : "none";
      keywordFilterSection.style.display = isAnyChecked ? "block" : "none";
    }
  };

  const handleChannelSwitch = (event, channelType) => {
    const { customChannelSwitch, broadcastChannelSwitch, groupChannelSwitch, nestedOptions, contributorOr, contributorAnd } = elements;
    const switches = [customChannelSwitch, broadcastChannelSwitch, groupChannelSwitch];

    switches.forEach((switchElement) => {
      if (switchElement !== event.target) {
        switchElement.checked = false;
      }
    });

    const shouldShowNestedOptions = customChannelSwitch.checked;
    nestedOptions.classList.toggle("show", shouldShowNestedOptions);

    if (!shouldShowNestedOptions) {
      contributorOr.checked = false;
      contributorAnd.checked = false;
      toggleVisibility();
    }

    const activeChannelType = customChannelSwitch.checked ? "custom_channel" : broadcastChannelSwitch.checked ? "broadcast_channel" : groupChannelSwitch.checked ? "group_channel" : null;
    createOrUpdateContentType(activeChannelType);
  };

  if (elements.contributorOr) {
    elements.contributorOr.addEventListener("change", () => {
      toggleCheckboxes(elements.contributorOr, elements.contributorAnd);
      createOrUpdateContentType("custom_channel");
    });
  }
  if (elements.contributorAnd) {
    elements.contributorAnd.addEventListener("change", () => {
      toggleCheckboxes(elements.contributorAnd, elements.contributorOr);
      createOrUpdateContentType("custom_channel");
    });
  }

  const toggleCheckboxes = (primary, secondary) => {
    if (primary.checked) {
      secondary.checked = false;
    }
  };

  initializeFormState();

  if (elements.customChannelSwitch) {
    elements.customChannelSwitch.addEventListener("change", (e) => handleChannelSwitch(e, "custom_channel"));
  }

  if (elements.broadcastChannelSwitch) {
    elements.broadcastChannelSwitch.addEventListener("change", (e) => handleChannelSwitch(e, "broadcast_channel"));
  }

  if (elements.groupChannelSwitch) {
    elements.groupChannelSwitch.addEventListener("change", (e) => handleChannelSwitch(e, "group_channel"));
  }

  if (elements.contributorAnd) {
    elements.contributorOr.addEventListener("change", toggleVisibility);
  }

  if (elements.contributorAnd) {
    elements.contributorAnd.addEventListener("change", toggleVisibility);
  }

  toggleVisibility();
});
