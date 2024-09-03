function searchFollowedContributors(query) {
  if (query.length === 0) {
    clearSearchResults();
    return;
  }

  showLoadingSpinner();

  fetch(`/communities/search_contributor?query=${encodeURIComponent(query)}`)
    .then(response => response.json())
    .then(data => {
      hideLoadingSpinner();
      displaySearchResults(data.accounts);
    })
    .catch(error => {
      hideLoadingSpinner();
      console.log('Error fetching search results:', error);
    });
}

// Function to show the loading spinner and disable background
function showLoadingSpinner() {
  document.getElementById('disabled-overlay').style.display = 'flex';
}

// Function to hide the loading spinner and enable background
function hideLoadingSpinner() {
  document.getElementById('disabled-overlay').style.display = 'none';
}

// Function to display search results in the modal
function displaySearchResults(accounts) {
  const resultsContainer = document.getElementById('mute-search-results');
  resultsContainer.innerHTML = '';

  if (accounts.length === 0) {
    resultsContainer.innerHTML = '<p>No results found.</p>';
    return;
  }

  accounts.forEach(account => {
    const resultItem = document.createElement('div');
    resultItem.className = 'list-group-item align-items-center';
    resultItem.innerHTML = `
      <div class="profile-info row">
        <div class="col-auto">
          <img src="${account.avatar}" alt="${account.username}" class="rounded-circle mr-2" style="width: 70px; height: 70px;">
        </div>
        <div class="col">
          <p class="mb-0">${account.display_name || account.username}</p>
          <small class="text-muted">@${account.acct}</small>
          ${account.note ? `<small class="small">${account.note}</small>` : ''}
        </div>
        <div class="col-auto ml-5 pl-5 mt-5">
          <button class="btn btn-outline-secondary mute-button" data-account-id="${account.id}" style="float: right;">
            ${isMuted(account.id) ? 'Unmute' : 'Mute'}
          </button>
        </div>
      </div>
    `;

    resultsContainer.appendChild(resultItem);
  });

  // Add event listeners for mute buttons
  document.querySelectorAll('.mute-button').forEach(button => {
    button.addEventListener('click', function() {
      const accountId = this.dataset.accountId;
      toggleMute(accountId); // Define this function to handle the mute/unmute action
    });
  });
}

// Function to clear the search results
function clearSearchResults() {
  const resultsContainer = document.getElementById('mute-search-results');
  resultsContainer.innerHTML = '';
}

// Function to check if account is muted
function isMuted(accountId) {
  // Implement your logic to check if the account is muted
  return false;
}

// Event listener for the search box in the mute contributor modal
const muteSearchInput = document.getElementById('mute-search-input');
if (muteSearchInput) {
  muteSearchInput.addEventListener('keydown', function(event) {
    if (event.key === 'Enter' || event.keyCode === 13) {
      searchFollowedContributors(this.value);
    }
  });
}

// Add toggleMute function here to handle muting/unmuting
