
const sidebarLinks = document.querySelectorAll(".nav-sidebar .nav-link");

sidebarLinks.forEach(link => {
  link.addEventListener("click", function () {
    const headerTitle = document.getElementById("header-title");
    headerTitle.textContent = this.dataset.header;
  });
});


const activeLink = document.querySelector(".nav-sidebar .nav-link.active");
if (activeLink) {
  const headerTitle = document.getElementById("header-title");
  headerTitle.textContent = activeLink.dataset.header;
}

