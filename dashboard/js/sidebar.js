const pathname = window.location.pathname;
const currentPage = pathname.endsWith("/") ? "index.html" : pathname.split("/").pop() || "index.html";

document.querySelectorAll(".sidebar .menu-item[href]").forEach((item) => {
    const linkPage = new URL(item.href, window.location.href).pathname.replace(/\/+$/, "").split("/").pop();
    const isCurrentPage = linkPage === currentPage;

    item.classList.toggle("active", isCurrentPage);
    if (isCurrentPage) {
        item.setAttribute("aria-current", "page");
    } else {
        item.removeAttribute("aria-current");
    }
});
