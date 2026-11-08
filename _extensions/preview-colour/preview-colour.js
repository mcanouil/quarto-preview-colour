/**
 * Preview Colour Extension - copy the colour of a mark to the clipboard
 *
 * @author Mickaël Canouil
 *
 * Each mark is a button that holds its colour in `data-colour`. One listener
 * on the document handles every mark. The result of the copy is shown in a
 * short tooltip, and is also written to one polite live region, so that a
 * screen reader announces it. The live region exists before the first copy,
 * because a screen reader can miss a region that is added and filled at the
 * same time.
 */

(() => {
  const TOOLTIP_DURATION = 1500;
  const STATUS_DURATION = 3000;
  const STATUS_DELAY = 100;
  let status = null;
  let statusTimer = null;

  const createStatus = () => {
    status = document.createElement('div');
    status.className = 'preview-colour-status';
    status.setAttribute('role', 'status');
    status.setAttribute('aria-live', 'polite');
    document.body.appendChild(status);
  };

  const announce = (message) => {
    clearTimeout(statusTimer);
    status.textContent = '';
    statusTimer = setTimeout(() => {
      status.textContent = message;
      statusTimer = setTimeout(() => {
        status.textContent = '';
      }, STATUS_DURATION);
    }, STATUS_DELAY);
  };

  const showTooltip = (mark, message) => {
    mark.querySelector('.preview-colour-tooltip')?.remove();
    const tooltip = document.createElement('span');
    tooltip.className = 'preview-colour-tooltip';
    tooltip.setAttribute('aria-hidden', 'true');
    tooltip.textContent = message;
    mark.appendChild(tooltip);
    setTimeout(() => tooltip.remove(), TOOLTIP_DURATION);
  };

  const copy = (mark) => {
    const value = mark.dataset.colour;
    // The clipboard API is missing outside a secure context, such as a page
    // opened from `file://` in some browsers, so its absence is a failure too.
    Promise.resolve().then(() => navigator.clipboard.writeText(value)).then(
      () => {
        showTooltip(mark, 'Copied!');
        announce(`Copied ${value}`);
      },
      (error) => {
        console.error(`preview-colour: could not copy "${value}" to the clipboard.`, error);
        showTooltip(mark, 'Copy failed');
        announce(`Could not copy ${value}`);
      },
    );
  };

  const init = () => {
    createStatus();
    document.addEventListener('click', (event) => {
      const mark = event.target.closest('button.preview-colour');
      if (mark) copy(mark);
    });
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
