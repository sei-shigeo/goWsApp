package handlers

import (
	"net/http"
	"strconv"

	"github.com/sei-shigeo/webApp/db"
	"github.com/sei-shigeo/webApp/views/pages"
)

var queries *db.Queries

// SetDB はデータベースクエリインスタンスを設定します
func SetDB(q *db.Queries) {
	queries = q
}

func EmployeesHandler(w http.ResponseWriter, r *http.Request) {
	employees, err := queries.GetEmployeeCardList(r.Context(), db.GetEmployeeCardListParams{
		Limit:  10,
		Offset: 0,
	})
	if err != nil {
		http.Error(w, "Failed to get employee card list", http.StatusInternalServerError)
		return
	}
	pages.Employees(employees).Render(r.Context(), w)
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
