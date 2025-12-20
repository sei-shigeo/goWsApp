package handlers

import (
	"net/http"
	"strconv"

	"github.com/sei-shigeo/webApp/views/pages"
)

func EmployeesHandler(w http.ResponseWriter, r *http.Request) {

	pages.Employees().Render(r.Context(), w)
}

func EmployeesPrintHandler(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	idInt, err := strconv.Atoi(id)
	if err != nil {
		http.Error(w, "Invalid ID", http.StatusBadRequest)
		return
	}

	pages.EmployeesPrint(idInt).Render(r.Context(), w)
}
