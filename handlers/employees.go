package handlers

import (
	"net/http"
	"strconv"

	"github.com/sei-shigeo/webApp/db"
	"github.com/sei-shigeo/webApp/views/pages"
)

// EmployeesRouter は従業員関連のすべてのルーティングを設定します
func (a *App) EmployeesRouter() error {

	// EmployeesHandler は従業員一覧ページを表示します
	a.mux.HandleFunc("GET /employees", func(w http.ResponseWriter, r *http.Request) {
		employees, err := a.db.GetEmployeeCardList(r.Context(), db.GetEmployeeCardListParams{
			Limit:  10,
			Offset: 0,
		})
		if err != nil {
			http.Error(w, "Failed to get employee card list", http.StatusInternalServerError)
			return
		}
		pages.Employees(employees).Render(r.Context(), w)
	})

	// EmployeesDetailsHandler は従業員詳細ページを表示します
	// GetEmployeeAllData()を使用してすべてのデータを取得します
	a.mux.HandleFunc("GET /employees/details/{id}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		idInt, err := strconv.Atoi(id)
		if err != nil {
			http.Error(w, "Invalid ID", http.StatusBadRequest)
			return
		}

		// すべてのデータを取得（リポジトリ関数を使用）
		pageData, err := a.GetEmployeeDetailsData(r.Context(), int32(idInt))
		if err != nil {
			http.Error(w, "Failed to get employee all data", http.StatusInternalServerError)
			return
		}

		pageData.EmployeesDetails().Render(r.Context(), w)
	})

	// EmployeesPrintHandler は従業員印刷ページを表示します
	a.mux.HandleFunc("GET /employees/print/{id}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		idInt, err := strconv.Atoi(id)
		if err != nil {
			http.Error(w, "Invalid ID", http.StatusBadRequest)
			return
		}

		pages.EmployeesPrint(idInt).Render(r.Context(), w)
	})

	// EmployeesCreateHandler は従業員作成ページを表示します
	a.mux.HandleFunc("GET /employees/create", func(w http.ResponseWriter, r *http.Request) {
		pages.EmployeesCreate().Render(r.Context(), w)
	})

	return nil
}
