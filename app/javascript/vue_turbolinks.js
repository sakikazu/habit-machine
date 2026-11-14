// Turbolinks上でVueアプリを一度だけマウントし、画面差し替え前に破棄する
export const mountVueOnTurbolinks = (selector, createAppForElement) => {
  const mountedApps = new Map()

  const unmountCurrentPage = () => {
    mountedApps.forEach((app, element) => {
      if (!document.documentElement.contains(element)) return
      app.unmount()
      mountedApps.delete(element)
    })
  }

  document.addEventListener('turbolinks:before-render', unmountCurrentPage)
  document.addEventListener('turbolinks:load', () => {
    document.querySelectorAll(selector).forEach((element) => {
      if (mountedApps.has(element)) return
      const app = createAppForElement(element)
      app.mount(element)
      mountedApps.set(element, app)
    })
  })
}
