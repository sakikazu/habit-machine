// Turbolinks上でVueアプリを一度だけマウントし、画面差し替え前に破棄する
export const mountVueOnTurbolinks = (selector, createAppForElement) => {
  // ページ固有bundleが再評価されてもdocumentイベントを重複登録しない
  window.habitMachineVueMounts ||= new Map()
  if (window.habitMachineVueMounts.has(selector)) return

  const mountedApps = new Map()

  const unmountCurrentPage = () => {
    mountedApps.forEach((app, element) => {
      if (!document.documentElement.contains(element)) return
      app.unmount()
      mountedApps.delete(element)
    })
  }

  document.addEventListener('turbolinks:before-render', unmountCurrentPage)
  const mountCurrentPage = () => {
    document.querySelectorAll(selector).forEach((element) => {
      if (mountedApps.has(element)) return
      const app = createAppForElement(element)
      app.mount(element)
      mountedApps.set(element, app)
    })
  }

  document.addEventListener('turbolinks:load', mountCurrentPage)
  window.habitMachineVueMounts.set(selector, { unmountCurrentPage, mountCurrentPage })
}
