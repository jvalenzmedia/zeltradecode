/* ZelTrade Code - redeem panel (vanilla JS). The client / server validate the code again. */
const $ = (id) => document.getElementById(id);
const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'zeltradecode';
let texts = {};

function post(name, data) {
    return fetch(`https://${resource}/${name}`, { method: 'POST', body: JSON.stringify(data || {}) }).catch(() => {});
}

function setBusy(busy) {
    const btn = $('canjear');
    btn.disabled = busy;
    btn.querySelector('span').textContent = busy ? texts.ui_redeeming : texts.ui_redeem;
}

function showResult(ok, msg) {
    setBusy(false);
    const r = $('resultado');
    r.textContent = msg || '';
    r.className = 'resultado ' + (ok ? 'ok' : 'error');
    if (ok) $('codigo').value = '';
}

function open(d) {
    texts = d.texts || {};
    document.querySelectorAll('[data-t]').forEach((e) => {
        const t = texts[e.dataset.t];
        if (!t) return;
        if (e.tagName === 'BUTTON' && e.classList.contains('cerrar')) e.title = t;
        else e.textContent = t;
    });
    $('codigo').placeholder = texts.ui_placeholder || '';
    $('servidor').textContent = d.serverName || '';
    $('version').textContent = d.version ? 'v' + d.version : '';

    const logo = $('logo');
    logo.classList.toggle('oculto', !d.logo);
    $('logo-icono').classList.toggle('oculto', !!d.logo);
    if (d.logo) logo.src = d.logo;
    const banner = $('banner-img');
    banner.classList.toggle('oculto', !d.banner);
    if (d.banner) banner.src = d.banner;

    $('codigo').value = '';
    $('resultado').textContent = '';
    setBusy(false);
    $('panel').classList.remove('oculto');
    setTimeout(() => $('codigo').focus(), 50);
}

function close() {
    $('panel').classList.add('oculto');
    post('close');
}

function redeem() {
    const code = $('codigo').value.replace(/\s/g, '').toUpperCase();
    if (!code || $('canjear').disabled) return;
    setBusy(true);
    $('resultado').textContent = '';
    post('redeem', { code });
}

$('logo').addEventListener('error', () => { $('logo').classList.add('oculto'); $('logo-icono').classList.remove('oculto'); });
$('banner-img').addEventListener('error', () => $('banner-img').classList.add('oculto'));
$('cerrar').addEventListener('click', close);
$('canjear').addEventListener('click', redeem);
$('codigo').addEventListener('keydown', (e) => { if (e.key === 'Enter') redeem(); });
document.addEventListener('keydown', (e) => { if (e.key === 'Escape') close(); });

window.addEventListener('message', (e) => {
    const m = e.data || {};
    if (m.action === 'open') open(m);
    else if (m.action === 'close') $('panel').classList.add('oculto');
    else if (m.action === 'result') showResult(m.success, m.msg);
});
