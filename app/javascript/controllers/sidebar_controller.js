import { Controller } from "@hotwired/stimulus"

// Sidebar controller for collapse/expand functionality
export default class extends Controller {
  connect() {
    // Restore collapsed state from localStorage
    const isCollapsed = localStorage.getItem('sidebarCollapsed') === 'true'
    if (isCollapsed) {
      this.element.classList.add('sidebar-collapsed')
    }
  }

  toggle() {
    this.element.classList.toggle('sidebar-collapsed')
    const isCollapsed = this.element.classList.contains('sidebar-collapsed')
    localStorage.setItem('sidebarCollapsed', isCollapsed)
  }

  openMobile() {
    const sidebar = this.element.querySelector('.sidebar')
    if (sidebar) {
      sidebar.classList.add('open')
    }
  }

  closeMobile() {
    const sidebar = this.element.querySelector('.sidebar')
    if (sidebar) {
      sidebar.classList.remove('open')
    }
  }
}
