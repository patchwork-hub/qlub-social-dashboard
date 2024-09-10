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

function showLoadingSpinner() {
  document.getElementById('disabled-overlay').style.display = 'flex';
}

function hideLoadingSpinner() {
  document.getElementById('disabled-overlay').style.display = 'none';
}

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
            Loading...
          </button>
        </div>
      </div>
    `;

    resultsContainer.appendChild(resultItem);

    isMuted(account.id).then(isMutedStatus => {
      const muteButton = resultItem.querySelector('.mute-button');
      muteButton.innerText = isMutedStatus ? 'Unmute' : 'Mute';
    });
  });

  document.querySelectorAll('.mute-button').forEach(button => {
    button.addEventListener('click', function() {
      const accountId = this.dataset.accountId;
      toggleMute(accountId);
    });
  });
}


function clearSearchResults() {
  const resultsContainer = document.getElementById('mute-search-results');
  resultsContainer.innerHTML = '';
}

function isMuted(accountId) {
  return fetch(`/communities/is_muted?account_id=${accountId}`)
    .then(response => response.json())
    .then(data => data.is_muted)
    .catch(error => {
      console.log('Error checking mute status:', error);
      return false;
    });
}

const muteSearchInput = document.getElementById('mute-search-input');
if (muteSearchInput) {
  muteSearchInput.addEventListener('keydown', function(event) {
    if (event.key === 'Enter' || event.keyCode === 13) {
      searchFollowedContributors(this.value);
    }
  });
}

function toggleMute(accountId) {
  isMuted(accountId).then(isCurrentlyMuted => {
    fetch(`/communities/mute_contributor`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      body: JSON.stringify({
        account_id: accountId,
        mute: !isCurrentlyMuted
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        document.querySelector(`.mute-button[data-account-id="${accountId}"]`).innerText = !isCurrentlyMuted ? 'Unmute' : 'Mute';
      } else {
        console.log('Failed to mute/unmute the account.');
      }
    })
    .catch(error => console.log('Error toggling mute:', error));
  });
}
