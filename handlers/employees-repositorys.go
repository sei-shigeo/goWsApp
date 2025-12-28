package handlers

import (
	"context"
	"fmt"

	"github.com/sei-shigeo/webApp/db"
	"github.com/sei-shigeo/webApp/views/pages"
)
// GetEmployeeBasicInfo は従業員の基本情報のみを取得します
func (a *App) GetEmployeeBasicInfo(ctx context.Context, employeeID int32) (db.GetEmployeeBasicInfoRow, error) {
	basicInfo, err := a.db.GetEmployeeBasicInfo(ctx, employeeID)
	if err != nil {
		return db.GetEmployeeBasicInfoRow{}, fmt.Errorf("failed to get basic info: %w", err)
	}
	return basicInfo, nil
}

// GetMasterDataList はマスタデータを取得します
func (a *App) GetMasterDataList(ctx context.Context) (
	nationalities []db.MNationality,
	jobTypes []db.MJobType,
	employmentTypes []db.MEmploymentType,
	departments []db.MDepartment,
	positions []db.MPosition,
	err error,
) {
	nationalities, err = a.db.GetAllMNationalities(ctx)
	if err != nil {
		return nil, nil, nil, nil, nil, fmt.Errorf("failed to get nationalities: %w", err)
	}
	jobTypes, err = a.db.GetAllMJobTypes(ctx)
	if err != nil {
		return nil, nil, nil, nil, nil, fmt.Errorf("failed to get job types: %w", err)
	}
	employmentTypes, err = a.db.GetAllMEmploymentTypes(ctx)
	if err != nil {
		return nil, nil, nil, nil, nil, fmt.Errorf("failed to get employment types: %w", err)
	}
	departments, err = a.db.GetAllMDepartments(ctx)
	if err != nil {
		return nil, nil, nil, nil, nil, fmt.Errorf("failed to get departments: %w", err)
	}
	positions, err = a.db.GetAllMPositions(ctx)
	if err != nil {
		return nil, nil, nil, nil, nil, fmt.Errorf("failed to get positions: %w", err)
	}
	return nationalities, jobTypes, employmentTypes, departments, positions, nil
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

	// マスタデータを取得
	nationalities, jobTypes, employmentTypes, departments, positions, err := a.GetMasterDataList(ctx)
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
		TrainingRecords:      trainingRecords,
		HealthCheckupRecords: healthCheckupRecords,
		QualificationRecords: qualificationRecords,
		InsuranceRecords:     insuranceRecords,
		EducationRecords:     educationRecords,
		CareerRecords:        careerRecords,
		AccidentRecords:      accidentRecords,
		ViolationRecords:     violationRecords,
		Nationalities:        nationalities,
		JobTypes:             jobTypes,
		EmploymentTypes:      employmentTypes,
		Departments:          departments,
		Positions:            positions,
	}, nil
}
