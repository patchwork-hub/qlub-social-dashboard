export function sendPatchRequest(url, data) {
  return fetch(url, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    },
    body: JSON.stringify(data)
  })
  .then(response => {
    if (!response.ok) {
      return response.json().then(error => {
        throw new Error(error.message || 'Failed to update');
      });
    }
    return response.json();
  });
}
