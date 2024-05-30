export function sendPatchRequest(url, data) {
  fetch(url, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    },
    body: JSON.stringify(data)
  })
  .then(response => response.json())
  .then(data => {
    console.log('Update successful', data);
  })
  .catch(error => {
    console.error('Failed to update:', error);
  });
}
