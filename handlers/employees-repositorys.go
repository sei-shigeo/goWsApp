package handlers

import (
	"context"
	"fmt"

	"github.com/sei-shigeo/webApp/db"
	"github.com/sei-shigeo/webApp/views/pages"
)

// =========================================
// 従業員データ取得用リポジトリ関数
// =========================================
//
// このファイルには従業員に関するデータ取得ロジックが含まれています。
// 各関数は独立して使用でき、必要なデータだけを取得できます。
//
// 使用例:
//
// 基本情報のみ（編集ページなど）
//   basicInfo, err := app.GetEmployeeBasicInfo(ctx, employeeID)
//
// 連絡先情報のみ（連絡先ページなど）
//   addresses, emails, phones, err := app.GetEmployeeContactInfo(ctx, employeeID)
//
// すべてのデータ（詳細ページなど）
//   allData, err := app.GetEmployeeAllData(ctx, employeeID)
//
// =========================================

// =========================================
// 小さな再利用可能な関数群
// =========================================

// GetEmployeeBasicInfo は従業員の基本情報のみを取得します
func (a *App) GetEmployeeBasicInfo(ctx context.Context, employeeID int32) (db.GetEmployeeBasicInfoRow, error) {
	basicInfo, err := a.db.GetEmployeeBasicInfo(ctx, employeeID)
	if err != nil {
		return db.GetEmployeeBasicInfoRow{}, fmt.Errorf("failed to get basic info: %w", err)
	}
	return basicInfo, nil
}

// GetEmployeeEmergencyContacts は従業員の緊急連絡先を取得します
func (a *App) GetEmployeeEmergencyContacts(ctx context.Context, employeeID int32) ([]db.EmergencyContact, error) {
	emergencyContacts, err := a.db.GetEmployeeEmergencyContacts(ctx, employeeID)
	if err != nil {
		return nil, fmt.Errorf("failed to get emergency contacts: %w", err)
	}
	return emergencyContacts, nil
}

// GetEmployeeRecords は従業員の各種記録（教育訓練、健康診断、資格、保険）を取得します
func (a *App) GetEmployeeRecords(ctx context.Context, employeeID int32) (
	trainingRecords []db.TrainingRecord,
	healthCheckupRecords []db.HealthCheckupRecord,
	qualificationRecords []db.QualificationRecord,
	insuranceRecords []db.InsuranceRecord,
	err error,
) {
	// 教育訓練を取得
	trainingRecords, err = a.db.GetEmployeeTrainingRecords(ctx, employeeID)
	if err != nil {
		return nil, nil, nil, nil, fmt.Errorf("failed to get training records: %w", err)
	}

	// 健康診断を取得
	healthCheckupRecords, err = a.db.GetEmployeeHealthCheckupRecords(ctx, employeeID)
	if err != nil {
		return nil, nil, nil, nil, fmt.Errorf("failed to get health checkup records: %w", err)
	}

	// 資格を取得
	qualificationRecords, err = a.db.GetEmployeeQualificationRecords(ctx, employeeID)
	if err != nil {
		return nil, nil, nil, nil, fmt.Errorf("failed to get qualification records: %w", err)
	}

	// 保険を取得
	insuranceRecords, err = a.db.GetEmployeeInsuranceRecords(ctx, employeeID)
	if err != nil {
		return nil, nil, nil, nil, fmt.Errorf("failed to get insurance records: %w", err)
	}

	return trainingRecords, healthCheckupRecords, qualificationRecords, insuranceRecords, nil
}

// GetEmployeeEducationAndCareerRecords は従業員の学歴記録と職歴記録を取得します
func (a *App) GetEmployeeEducationAndCareerRecords(ctx context.Context, employeeID int32) (
	educationRecords []db.EducationRecord,
	careerRecords []db.CareerRecord,
	err error,
) {
	// 学歴を取得
	educationRecords, err = a.db.GetEmployeeEducationRecords(ctx, employeeID)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to get education records: %w", err)
	}
	// 職歴を取得
	careerRecords, err = a.db.GetEmployeeCareerRecords(ctx, employeeID)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to get career records: %w", err)
	}
	return educationRecords, careerRecords, nil
}

// GetEmployeeAccidentAndViolationRecords は従業員の事故履歴と違反履歴を取得します
func (a *App) GetEmployeeAccidentAndViolationRecords(ctx context.Context, employeeID int32) (
	accidentRecords []db.AccidentRecord,
	violationRecords []db.ViolationRecord,
	err error,
) {
	accidentRecords, err = a.db.GetEmployeeAccidentRecords(ctx, employeeID)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to get accident records: %w", err)
	}
	violationRecords, err = a.db.GetEmployeeViolationRecords(ctx, employeeID)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to get violation records: %w", err)
	}
	return accidentRecords, violationRecords, nil
}

// =========================================
// 統合関数
// =========================================

// GetEmployeeAllData は指定されたIDの従業員のすべての関連データを取得します
// 内部で小さな関数を組み合わせて使用するため、部分的なデータ取得も可能です
func (a *App) GetEmployeeDetailsData(ctx context.Context, employeeID int32) (*pages.EmployeesDetailsData, error) {
	// 基本情報を取得
	basicInfo, err := a.GetEmployeeBasicInfo(ctx, employeeID)
	if err != nil {
		return nil, err
	}

	// 緊急連絡先を取得
	emergencyContacts, err := a.GetEmployeeEmergencyContacts(ctx, employeeID)
	if err != nil {
		return nil, err
	}

	// 各種記録を取得
	trainingRecords, healthCheckupRecords, qualificationRecords, insuranceRecords, err := a.GetEmployeeRecords(ctx, employeeID)
	if err != nil {
		return nil, err
	}

	// 学歴 & 職歴を取得
	educationRecords, careerRecords, err := a.GetEmployeeEducationAndCareerRecords(ctx, employeeID)
	if err != nil {
		return nil, err
	}

	// 事故 & 違反を取得
	accidentRecords, violationRecords, err := a.GetEmployeeAccidentAndViolationRecords(ctx, employeeID)
	if err != nil {
		return nil, err
	}

	// すべてのデータを構造体にまとめて返す
	return &pages.EmployeesDetailsData{
		BasicInfo:            basicInfo,
		EmergencyContacts:    emergencyContacts,
		TrainingRecords:      trainingRecords,
		HealthCheckupRecords: healthCheckupRecords,
		QualificationRecords: qualificationRecords,
		InsuranceRecords:     insuranceRecords,
		EducationRecords:     educationRecords,
		CareerRecords:        careerRecords,
		AccidentRecords:      accidentRecords,
		ViolationRecords:     violationRecords,
	}, nil
}
