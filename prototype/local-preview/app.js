const tabs = [...document.querySelectorAll('.tab')];
const panels = [...document.querySelectorAll('.panel')];

function setActiveView(view) {
    tabs.forEach((tab) => {
        tab.classList.toggle('is-active', tab.dataset.view === view);
    });

    panels.forEach((panel) => {
        panel.classList.toggle('is-active', panel.id === view);
    });
}

tabs.forEach((tab) => {
    tab.addEventListener('click', () => setActiveView(tab.dataset.view));
});
