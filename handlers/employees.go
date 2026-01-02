package handlers

import (
	"fmt"
	"net/http"
	"strconv"

	"github.com/sei-shigeo/webApp/db"
	"github.com/sei-shigeo/webApp/utils"
	"github.com/sei-shigeo/webApp/views/pages"
	"github.com/starfederation/datastar-go/datastar"
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

		nationalities, err := a.db.GetNationalities(r.Context())
		if err != nil {
			http.Error(w, "Failed to get nationalities", http.StatusInternalServerError)
			return
		}

		d := pages.EmployeesPageData{
			Employees: employees,
			Nationalities: nationalities,
		}
		d.EmployeesPage().Render(r.Context(), w)
	})

	// EmployeesDetailsHandler は従業員詳細ページを表示します
	a.mux.HandleFunc("GET /employees/details/{id}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		idInt, err := strconv.Atoi(id)
		if err != nil {
			http.Error(w, "Invalid ID", http.StatusBadRequest)
			return
		}

		// すべてのデータを取得（リポジトリ関数を使用）
		pageData, err := a.GetEmployeeDetailsData(r.Context(), int64(idInt))
		if err != nil {
			http.Error(w, "Failed to get employee all data", http.StatusInternalServerError)
			return
		}

		pageData.EmployeesDetails().Render(r.Context(), w)
	})


	a.mux.HandleFunc("PATCH /employees/update/{id}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		idInt, err := strconv.Atoi(id)
		if err != nil {
			http.Error(w, "Invalid ID", http.StatusBadRequest)
			return
		}

		// フロントエンドから送られてくるシグナルは GetEmployeeBasicInfoRow の構造
		sig := &pages.EmployeeBasicInfoSignals{}
		if err := datastar.ReadSignals(r, sig); err != nil {
			http.Error(w, fmt.Sprintf("Failed to read signals: %v", err), 500)
			return
		}

		photoDate, err := utils.DateFromString(utils.StringOrEmpty(sig.EmployeePhotoDate))
		if err != nil {
			http.Error(w, "bad employee_photo_date", 400)
			return
		}

		visaExpiry, err := utils.DateFromString(utils.StringOrEmpty(sig.VisaExpiry))
		if err != nil {
			http.Error(w, "bad visa_expiry", 400)
			return
		}

		params := db.EmployeeBasicInfoUpdateParams{
			ID:                int64(idInt),
			EmployeeCode:      sig.EmployeeCode,
			EmployeeImageUrl:  sig.EmployeeImageUrl,
			EmployeePhotoDate: photoDate,

			LastName:      sig.LastName,
			FirstName:     sig.FirstName,
			LastNameKana:  sig.LastNameKana,
			FirstNameKana: sig.FirstNameKana,
			LegalName:     sig.LegalName,
			Gender:        sig.Gender,
			BloodType:     sig.BloodType,

			Address: sig.Address,
			Phone:   sig.Phone,
			Email:   sig.Email,

			EmergencyContactRelationship: sig.EmergencyContactRelationship,
			EmergencyContactName:         sig.EmergencyContactName,
			EmergencyContactPhone:        sig.EmergencyContactPhone,
			EmergencyContactEmail:        sig.EmergencyContactEmail,
			EmergencyContactAddress:      sig.EmergencyContactAddress,

			NationalityID: sig.NationalityID,
			VisaType:   sig.VisaType,
			VisaExpiry: visaExpiry,
		}

		updateEmployee, err := a.db.EmployeeBasicInfoUpdate(r.Context(), params)
		if err != nil {
			http.Error(w, fmt.Sprintf("Failed to update employee basic info: %v", err), http.StatusInternalServerError)
			return
		}

		fmt.Println("updateEmployee: ", updateEmployee)

		sse := datastar.NewSSE(w, r)
		sse.MarshalAndPatchSignals(sig)
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
		pages.EmployeesCreatePage().Render(r.Context(), w)
	})

	// EmployeesCreatePostHandler は従業員作成を行います
	a.mux.HandleFunc("POST /employees/create", func(w http.ResponseWriter, r *http.Request) {
		sig := &pages.EmployeeBasicInfoSignals{}
		if err := datastar.ReadSignals(r, sig); err != nil {
			http.Error(w, fmt.Sprintf("Failed to read signals: %v", err), 500)
			return
		}

	})

	return nil
}
