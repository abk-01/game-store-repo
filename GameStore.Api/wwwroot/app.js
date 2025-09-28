const base = '';

async function fetchJson(path, opts) {
  const res = await fetch(base + path, opts);
  if (!res.ok) {
    // try to include response body in the error for better diagnostics
    let text;
    try { text = await res.text(); } catch (e) { text = '<unable to read response body>'; }
    throw new Error(`${res.status} ${res.statusText} - ${text}`);
  }
  return res.json();
}

async function loadGenres() {
  const list = document.getElementById('genres-list');
  const sel = document.getElementById('game-genre');
  list.innerHTML = 'Loading...';
  try {
    const genres = await fetchJson('/genres');
    sel.innerHTML = '';
    list.innerHTML = '';
    genres.forEach(g => {
      const d = document.createElement('div'); d.className='card'; d.textContent = `${g.id}: ${g.name}`; list.appendChild(d);
      const opt = document.createElement('option'); opt.value = g.id; opt.textContent = g.name; sel.appendChild(opt);
    });
  } catch (e) { list.innerHTML = 'Failed to load genres: ' + e }
}

async function loadGames() {
  const list = document.getElementById('games-list');
  list.innerHTML = 'Loading...';
  try {
    const games = await fetchJson('/games');
    list.innerHTML = '';
    games.forEach(g => {
      const d = document.createElement('div'); d.className='card';
        d.innerHTML = `<strong>${g.name}</strong> <small>(${g.id})</small><br/>Genre: ${g.genre} - Price: $${g.price}`;
  const edit = document.createElement('button'); edit.textContent='Edit'; edit.className='button small ghost'; edit.style.marginRight='8px'; edit.onclick = () => { startEdit(g); };
  const del = document.createElement('button'); del.textContent='Delete'; del.className='button small danger'; del.onclick = async () => { if (confirm('Delete this game?')) await deleteGame(g.id); };
  d.appendChild(edit);
  d.appendChild(del);
      list.appendChild(d);
    });
  } catch (e) { list.innerHTML = 'Failed to load games: ' + e }
}

async function createGame() {
  const id = document.getElementById('game-id').value;
  const name = document.getElementById('game-name').value;
  const genreId = parseInt(document.getElementById('game-genre').value,10);
  const price = parseFloat(document.getElementById('game-price').value) || 0;
  const releaseDate = document.getElementById('game-date').value;
  // Client-side validation to match server-side DTO requirements
  const errors = [];
  if (!name || name.trim().length === 0) errors.push('Name is required.');
  if (name && name.length > 50) errors.push('Name must be at most 50 characters.');
  if (isNaN(price) || price < 1 || price > 100) errors.push('Price must be between 1 and 100.');
  if (!releaseDate) errors.push('Release date is required.');
  if (errors.length) { alert('Please fix:\n' + errors.join('\n')); return; }
  const btn = document.getElementById('create-game');
  btn.disabled = true;
  try {
    if (id) {
      // Update
      await fetchJson('/games/' + id, { method: 'PUT', headers: { 'Content-Type':'application/json' }, body: JSON.stringify({ id: parseInt(id,10), name, genreId, price, releaseDate }) });
      endEdit();
    } else {
      // Create
      await fetchJson('/games', { method: 'POST', headers: { 'Content-Type':'application/json' }, body: JSON.stringify({ name, genreId, price, releaseDate }) });
    }
    await loadGames();
  } catch (e) {
    // Include server response when available
    const prefix = id ? 'Update' : 'Create';
    if (e && e.message) alert(prefix + ' failed: ' + e.message);
    else alert(prefix + ' failed');
  } finally {
    btn.disabled = false;
  }
}

function startEdit(g) {
  document.getElementById('form-title').textContent = 'Edit Game';
  document.getElementById('game-id').value = g.id;
  document.getElementById('game-name').value = g.name || '';
  document.getElementById('game-genre').value = g.genreId || '';
  document.getElementById('game-price').value = g.price || '';
  document.getElementById('game-date').value = g.releaseDate ? g.releaseDate.split('T')[0] : '';
  document.getElementById('create-game').textContent = 'Save';
  document.getElementById('cancel-edit').style.display = 'inline-block';
}

function endEdit() {
  document.getElementById('form-title').textContent = 'Create Game';
  document.getElementById('game-id').value = '';
  document.getElementById('game-name').value = '';
  document.getElementById('game-price').value = '';
  document.getElementById('game-date').value = '';
  document.getElementById('create-game').textContent = 'Create';
  document.getElementById('cancel-edit').style.display = 'none';
}

  document.getElementById('cancel-edit').addEventListener('click', (e) => { e.preventDefault(); endEdit(); });

// Style form buttons
document.getElementById('create-game').className = 'button';
document.getElementById('cancel-edit').className = 'button ghost';

async function deleteGame(id) {
  try {
    const res = await fetch('/games/' + id, { method: 'DELETE' });
    if (res.status === 204) {
      await loadGames();
    } else {
      const text = await res.text();
      alert('Delete failed: ' + res.status + ' ' + res.statusText + '\n' + text);
    }
  } catch (e) { alert('Delete failed: ' + e) }
}

document.getElementById('create-game').addEventListener('click', createGame);

loadGenres();
loadGames();
