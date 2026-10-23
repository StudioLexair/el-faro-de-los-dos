'use strict';
// The APK is served by THIS site. No redirect, window.open or external download host.
let release = null;
const buttons = [...document.querySelectorAll('[data-download]')];
const versions = [...document.querySelectorAll('[data-version]')];
const statuses = [...document.querySelectorAll('[data-download-status]')];
function say(message) { statuses.forEach(node => { node.textContent = message; }); }
async function loadRelease() {
  try {
    const response = await fetch('/download.json', {cache: 'no-store', credentials: 'omit'});
    if (!response.ok) throw new Error('Version metadata unavailable');
    const data = await response.json();
    if (data.available !== true || !data.apkUrl || !data.filename || !data.sha256) {
      versions.forEach(node => { node.textContent = 'La primera versión se está preparando en GitHub Actions.'; });
      return;
    }
    const url = new URL(data.apkUrl, window.location.origin);
    if (url.origin !== window.location.origin || !url.pathname.startsWith('/downloads/') || !url.pathname.endsWith('.apk')) {
      throw new Error('Download must use the same origin');
    }
    release = {...data, url: url.href};
    const mb = new Intl.NumberFormat('es', {maximumFractionDigits: 1}).format(data.sizeBytes / 1e6);
    versions.forEach(node => { node.textContent = `Versión ${data.version} · Android ${data.minimumAndroid}+ · ${mb} MB`; });
    document.getElementById('apk-checksum').textContent = data.sha256;
    if (data.repositoryUrl && data.repositoryUrl.startsWith('https://github.com/')) {
      document.getElementById('source-link').href = data.repositoryUrl;
    }
    buttons.forEach(button => { button.disabled = false; });
  } catch (_) {
    versions.forEach(node => { node.textContent = 'No se pudo comprobar la versión. Vuelve a cargar la página.'; });
  }
}
buttons.forEach(button => button.addEventListener('click', () => {
  if (!release) return;
  const anchor = document.createElement('a');
  anchor.href = release.url;
  anchor.download = release.filename;
  anchor.hidden = true;
  document.body.append(anchor);
  anchor.click();
  anchor.remove();
  // Native browser download. The document and number of tabs remain unchanged.
  say('Descarga solicitada. Si tu navegador pide confirmación, acéptala para guardar el APK.');
}));

let dialogOpener = null;
document.querySelectorAll('[data-dialog]').forEach(button => button.addEventListener('click', () => {
  const dialog = document.getElementById(button.dataset.dialog);
  dialogOpener = button;
  dialog.showModal();
  document.body.style.overflow = 'hidden';
}));
document.querySelectorAll('dialog').forEach(dialog => {
  dialog.querySelector('.dialog-close').addEventListener('click', () => dialog.close());
  dialog.addEventListener('close', () => { document.body.style.overflow = ''; if (dialogOpener) dialogOpener.focus(); });
  dialog.addEventListener('click', event => {
    if (event.target !== dialog) return;
    const rect = dialog.getBoundingClientRect();
    if (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom) dialog.close();
  });
});
document.getElementById('year').textContent = String(new Date().getFullYear());
loadRelease();
