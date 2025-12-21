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

// EmployeesHandler は従業員一覧ページを表示します
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

// EmployeesBasicInfoHandler は従業員基本情報ページを表示します
func EmployeesBasicInfoHandler(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	idInt, err := strconv.Atoi(id)
	if err != nil {
		http.Error(w, "Invalid ID", http.StatusBadRequest)
		return
	}

	// 基本情報を取得
	basicInfo, err := queries.GetEmployeeBasicInfo(r.Context(), int32(idInt))
	if err != nil {
		http.Error(w, "Failed to get employee basic info", http.StatusInternalServerError)
		return
	}
	// 銀行口座を取得
	banks, err := queries.GetEmployeeBanks(r.Context(), int32(idInt))
	if err != nil {
		http.Error(w, "Failed to get employee banks", http.StatusInternalServerError)
		return
	}

	// 住所を取得
	addresses, err := queries.GetEmployeeAddresses(r.Context(), int32(idInt))
	if err != nil {
		http.Error(w, "Failed to get employee addresses", http.StatusInternalServerError)
		return
	}

	// メールアドレスを取得
	emails, err := queries.GetEmployeeEmails(r.Context(), int32(idInt))
	if err != nil {
		http.Error(w, "Failed to get employee emails", http.StatusInternalServerError)
		return
	}

	// 電話番号を取得
	phones, err := queries.GetEmployeePhones(r.Context(), int32(idInt))
	if err != nil {
		http.Error(w, "Failed to get employee phones", http.StatusInternalServerError)
		return
	}

	// 緊急連絡先を取得
	emergencyContacts, err := queries.GetEmployeeEmergencyContacts(r.Context(), int32(idInt))
	if err != nil {
		http.Error(w, "Failed to get employee emergency contacts", http.StatusInternalServerError)
		return
	}

	// 教育訓練を取得
	trainingRecords, err := queries.GetEmployeeTrainingRecords(r.Context(), int32(idInt))
	if err != nil {
		http.Error(w, "Failed to get employee training records", http.StatusInternalServerError)
		return
	}

	// 健康診断を取得
	healthCheckupRecords, err := queries.GetEmployeeHealthCheckupRecords(r.Context(), int32(idInt))
	if err != nil {
		http.Error(w, "Failed to get employee health checkup records", http.StatusInternalServerError)
		return
	}

	// 資格を取得
	qualificationRecords, err := queries.GetEmployeeQualificationRecords(r.Context(), int32(idInt))
	if err != nil {
		http.Error(w, "Failed to get employee qualification records", http.StatusInternalServerError)
		return
	}

	// 保険を取得
	insuranceRecords, err := queries.GetEmployeeInsuranceRecords(r.Context(), int32(idInt))
	if err != nil {
		http.Error(w, "Failed to get employee insurance records", http.StatusInternalServerError)
		return
	}

	// 学歴を取得
	educationRecords, err := queries.GetEmployeeEducationRecords(r.Context(), int32(idInt))
	if err != nil {
		http.Error(w, "Failed to get employee education records", http.StatusInternalServerError)
		return
	}

	// 職歴を取得
	careerRecords, err := queries.GetEmployeeCareerRecords(r.Context(), int32(idInt))
	if err != nil {
		http.Error(w, "Failed to get employee career records", http.StatusInternalServerError)
		return
	}

	// 事故履歴を取得
	accidentRecords, err := queries.GetEmployeeAccidentRecords(r.Context(), int32(idInt))
	if err != nil {
		http.Error(w, "Failed to get employee accident records", http.StatusInternalServerError)
		return
	}

	// 違反履歴を取得
	violationRecords, err := queries.GetEmployeeViolationRecords(r.Context(), int32(idInt))
	if err != nil {
		http.Error(w, "Failed to get employee violation records", http.StatusInternalServerError)
		return
	}

	data := pages.EmployeesDetailsData{
		BasicInfo:            basicInfo,
		Banks:                banks,
		Addresses:            addresses,
		Emails:               emails,
		Phones:               phones,
		TrainingRecords:      trainingRecords,
		HealthCheckupRecords: healthCheckupRecords,
		QualificationRecords: qualificationRecords,
		InsuranceRecords:     insuranceRecords,
		EducationRecords:     educationRecords,
		CareerRecords:        careerRecords,
		AccidentRecords:      accidentRecords,
		ViolationRecords:     violationRecords,
		EmergencyContacts:    emergencyContacts,
	}

	data.EmployeesDetails().Render(r.Context(), w)
}

// EmployeesPrintHandler は従業員印刷ページを表示します
func EmployeesPrintHandler(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	idInt, err := strconv.Atoi(id)
	if err != nil {
		http.Error(w, "Invalid ID", http.StatusBadRequest)
		return
	}

	pages.EmployeesPrint(idInt).Render(r.Context(), w)
}

// EmployeesCreateHandler は従業員作成ページを表示します
func EmployeesCreateHandler(w http.ResponseWriter, r *http.Request) {
	pages.EmployeesCreate().Render(r.Context(), w)
}
