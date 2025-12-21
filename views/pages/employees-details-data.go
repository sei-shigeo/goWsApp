package pages

import (
	"fmt"

	"github.com/sei-shigeo/webApp/helpers"
)

// フィールドグループの種類を定数で定義
const (
	FieldGroupBasic            = "basic"
	FieldGroupEmail            = "email"
	FieldGroupPhone            = "phone"
	FieldGroupAddress          = "address"
	FieldGroupEmergencyContact = "emergency-contact"
	FieldGroupEmployment       = "employment"
	FieldGroupRetirement       = "retirement"
	FieldGroupDriverLicense    = "driver-license"
	FieldGroupVisa             = "visa"
	FieldGroupRole             = "role"
	FieldGroupStatus           = "status"
	FieldGroupBank             = "bank"
	FieldGroupTraining         = "training"
	FieldGroupHealthCheckup    = "health-checkup"
	FieldGroupQualification    = "qualification"
	FieldGroupInsurance        = "insurance"
	FieldGroupEducation        = "education"
	FieldGroupCareer           = "career"
	FieldGroupAccident         = "accident"
	FieldGroupViolation        = "violation"
)

// fieldGroupTypes は従業員詳細ページに表示される情報グループのタイプを定義します
// 表示される順序もこの配列の順序に従います
var fieldGroupTypes = []string{
	FieldGroupBasic,            // 基本情報
	FieldGroupEmail,            // メールアドレス
	FieldGroupPhone,            // 電話番号
	FieldGroupAddress,          // 住所
	FieldGroupEmergencyContact, // 緊急連絡先
	FieldGroupEmployment,       // 雇用情報
	FieldGroupRetirement,       // 退職情報
	FieldGroupDriverLicense,    // 運転免許情報
	FieldGroupVisa,             // 在留資格
	FieldGroupRole,             // 権限
	FieldGroupStatus,           // ステータス
	FieldGroupBank,             // 銀行口座
	FieldGroupTraining,         // 教育訓練
	FieldGroupHealthCheckup,    // 健康診断
	FieldGroupQualification,    // 資格
	FieldGroupInsurance,        // 保険
	FieldGroupEducation,        // 学歴
	FieldGroupCareer,           // 職歴
	FieldGroupAccident,         // 事故履歴
	FieldGroupViolation,        // 違反履歴
}

// fields は表示用のラベルと値のペアを表す構造体
type fields struct {
	Label string // フィールドのラベル（例: "従業員コード"）
	Value string // フィールドの値（例: "E-001"）
}

// EmployeesDetailsFieldsData は指定された情報タイプに基づいてフィールドのスライスを返します
// 複数レコードがある場合は、すべてのレコードを含むスライスを返します
func (d EmployeesDetailsData) EmployeesDetailsFieldsData(infoType string) []fields {
	switch infoType {
	case FieldGroupBasic:
		// 基本情報: 従業員の基本的な個人情報
		// 従業員画像が存在する場合はそのURLを使用し、存在しない場合はプレースホルダー画像を使用
		employeeImageValue := "https://placehold.jp/150x150.png"
		if d.BasicInfo.EmployeeImageUrl != nil {
			employeeImageValue = helpers.StringOf(d.BasicInfo.EmployeeImageUrl)
		}

		// 氏名を結合（姓 名）
		fullName := d.BasicInfo.LastName + " " + d.BasicInfo.FirstName
		fullNameKana := helpers.StringOf(d.BasicInfo.LastNameKana) + " " + helpers.StringOf(d.BasicInfo.FirstNameKana)

		// 性別の表示値を設定（男/女以外は"-"で表示）
		genderValue := d.BasicInfo.Gender
		if genderValue != "男" && genderValue != "女" {
			genderValue = "-"
		}

		return []fields{
			{Label: "従業員コード", Value: d.BasicInfo.EmployeeCode},
			{Label: "従業員画像", Value: employeeImageValue},
			{Label: "従業員写真日", Value: helpers.DateOf(d.BasicInfo.EmployeePhotoDate)},
			{Label: "名前", Value: fullName},
			{Label: "名前（カナ）", Value: fullNameKana},
			{Label: "正式名", Value: helpers.StringOf(d.BasicInfo.LegalName)},
			{Label: "性別", Value: genderValue},
			{Label: "生年月日", Value: helpers.DateOf(d.BasicInfo.BirthDate)},
		}

	case FieldGroupEmail:
		// メールアドレス情報: すべてのメールアドレスを表示
		var info []fields
		for i, email := range d.Emails {
			info = append(info, fields{
				Label: fmt.Sprintf("メールアドレス %d", i+1),
				Value: email.Email,
			})
		}
		return info

	case FieldGroupPhone:
		// 電話番号情報: すべての電話番号を種別付きで表示
		var info []fields
		for i, phone := range d.Phones {
			label := fmt.Sprintf("電話番号 %d", i+1)
			switch phone.PhoneType {
			case "固定電話":
				label = fmt.Sprintf("固定電話 %d", i+1)
			case "携帯電話":
				label = fmt.Sprintf("携帯電話 %d", i+1)
			case "内線":
				label = fmt.Sprintf("内線 %d", i+1)
			}
			info = append(info, fields{
				Label: label,
				Value: phone.PhoneNumber,
			})
		}
		return info

	case FieldGroupAddress:
		// 住所情報: すべての住所を表示
		var info []fields
		for i, address := range d.Addresses {
			addressValue := fmt.Sprintf("%s %s %s %s %s",
				helpers.StringOf(address.PostalCode),
				helpers.StringOf(address.Prefecture),
				helpers.StringOf(address.City),
				helpers.StringOf(address.StreetAddress),
				helpers.StringOf(address.BuildingName))
			info = append(info, fields{
				Label: fmt.Sprintf("住所 %d", i+1),
				Value: addressValue,
			})
		}
		return info

	case FieldGroupEmergencyContact:
		// 緊急連絡先情報: 緊急連絡先に関する詳細情報
		var info []fields
		for i, emergencyContact := range d.EmergencyContacts {
			emergencyContactValue := fmt.Sprintf("%s %s %s",
				helpers.StringOf(emergencyContact.ContactName),
				helpers.StringOf(emergencyContact.ContactRelationship),
				helpers.StringOf(emergencyContact.ContactPhone),
			)
			info = append(info, fields{
				Label: fmt.Sprintf("緊急連絡先 %d", i+1),
				Value: emergencyContactValue,
			})
		}
		return info

	case FieldGroupEmployment:
		// 雇用情報: 雇用に関する詳細情報
		officeInfo := helpers.StringOf(d.BasicInfo.OfficeName)
		if d.BasicInfo.OfficeType != nil {
			officeInfo += " " + helpers.StringOf(d.BasicInfo.OfficeType)
		}

		return []fields{
			{Label: "雇用日", Value: helpers.DateOf(d.BasicInfo.HireDate)},
			{Label: "選任日", Value: helpers.DateOf(d.BasicInfo.AppointmentDate)},
			{Label: "所属事業所", Value: officeInfo},
			{Label: "職種", Value: helpers.StringOf(d.BasicInfo.JobType)},
			{Label: "雇用形態", Value: helpers.StringOf(d.BasicInfo.EmploymentType)},
			{Label: "部署", Value: helpers.StringOf(d.BasicInfo.Department)},
			{Label: "役職", Value: helpers.StringOf(d.BasicInfo.Position)},
		}

	case FieldGroupRetirement:
		// 退職情報: 退職および死亡に関する情報
		return []fields{
			{Label: "退職日", Value: helpers.DateOf(d.BasicInfo.RetirementDate)},
			{Label: "退職理由", Value: helpers.StringOf(d.BasicInfo.RetirementReason)},
			{Label: "死亡日", Value: helpers.DateOf(d.BasicInfo.DeathDate)},
			{Label: "死亡理由", Value: helpers.StringOf(d.BasicInfo.DeathReason)},
		}

	case FieldGroupDriverLicense:
		// 運転免許情報: 運転免許に関する詳細
		return []fields{
			{Label: "運転免許番号", Value: helpers.StringOf(d.BasicInfo.DriverLicenseNo)},
			{Label: "運転免許種別", Value: helpers.StringOf(d.BasicInfo.DriverLicenseType)},
			{Label: "運転免許発行日", Value: helpers.DateOf(d.BasicInfo.DriverLicenseIssueDate)},
			{Label: "運転免許有効期限", Value: helpers.DateOf(d.BasicInfo.DriverLicenseExpiry)},
			{Label: "運転停止日", Value: helpers.DateOf(d.BasicInfo.DrivingDisabledDate)},
			{Label: "運転停止理由", Value: helpers.StringOf(d.BasicInfo.DrivingDisabledReason)},
		}

	case FieldGroupVisa:
		// 在留資格情報: 外国籍従業員の在留資格に関する情報
		return []fields{
			{Label: "国籍", Value: helpers.StringOf(d.BasicInfo.Nationality)},
			{Label: "在留資格", Value: helpers.StringOf(d.BasicInfo.VisaType)},
			{Label: "在留期限", Value: helpers.DateOf(d.BasicInfo.VisaExpiry)},
		}

	case FieldGroupRole:
		// 権限情報: システムへのアクセス権限
		return []fields{
			{Label: "権限", Value: helpers.StringOf(d.BasicInfo.RoleName)},
		}

	case FieldGroupStatus:
		// ステータス情報: 現在の在職状況
		statusValue := "退職"
		if d.BasicInfo.IsActive != nil && *d.BasicInfo.IsActive {
			statusValue = "在職中"
		}
		return []fields{
			{Label: "ステータス", Value: statusValue},
		}

	case FieldGroupBank:
		// 銀行口座情報: すべての銀行口座を表示
		var info []fields
		for i, bank := range d.Banks {
			bankValue := fmt.Sprintf("%s %s 口座番号: %s 名義: %s（%s）",
				helpers.StringOf(bank.BankName),
				helpers.StringOf(bank.BranchName),
				helpers.StringOf(bank.AccountNumber),
				helpers.StringOf(bank.AccountName),
				helpers.StringOf(bank.AccountKana),
			)
			info = append(info, fields{
				Label: fmt.Sprintf("銀行口座 %d", i+1),
				Value: bankValue,
			})
		}
		return info

	case FieldGroupTraining:
		// 教育訓練情報: すべての教育訓練記録を表示
		var info []fields
		for i, training := range d.TrainingRecords {
			trainingValue := fmt.Sprintf("%s（%s）講師: %s",
				training.TrainingType,
				helpers.DateOf(training.TrainingDate),
				helpers.StringOf(training.Instructor),
			)
			info = append(info, fields{
				Label: fmt.Sprintf("教育訓練 %d", i+1),
				Value: trainingValue,
			})
		}
		return info

	case FieldGroupHealthCheckup:
		// 健康診断情報: すべての健康診断記録を表示
		var info []fields
		for i, healthCheckup := range d.HealthCheckupRecords {
			healthCheckupValue := fmt.Sprintf("%s 結果: %s 医療機関: %s",
				helpers.StringOf(healthCheckup.CheckupType),
				helpers.StringOf(healthCheckup.OverallResult),
				helpers.StringOf(healthCheckup.MedicalInstitution),
			)
			info = append(info, fields{
				Label: fmt.Sprintf("健康診断 %d", i+1),
				Value: healthCheckupValue,
			})
		}
		return info

	case FieldGroupQualification:
		// 資格情報: すべての資格記録を表示
		var info []fields
		for i, qualification := range d.QualificationRecords {
			qualificationValue := fmt.Sprintf("%s（%s）番号: %s",
				helpers.StringOf(qualification.QualificationType),
				helpers.DateOf(qualification.QualificationDate),
				helpers.StringOf(qualification.QualificationNumber),
			)
			info = append(info, fields{
				Label: fmt.Sprintf("資格 %d", i+1),
				Value: qualificationValue,
			})
		}
		return info

	case FieldGroupInsurance:
		// 保険情報: すべての保険記録を表示
		var info []fields
		for i, insurance := range d.InsuranceRecords {
			insuranceValue := fmt.Sprintf("%s（%s）番号: %s",
				helpers.StringOf(insurance.InsuranceType),
				helpers.DateOf(insurance.InsuranceDate),
				helpers.StringOf(insurance.InsuranceNumber),
			)
			info = append(info, fields{
				Label: fmt.Sprintf("保険 %d", i+1),
				Value: insuranceValue,
			})
		}
		return info

	case FieldGroupEducation:
		// 学歴情報: すべての学歴記録を表示
		var info []fields
		for i, education := range d.EducationRecords {
			educationValue := fmt.Sprintf("%s %s（%s）",
				helpers.StringOf(education.EducationType),
				helpers.StringOf(education.EducationInstitution),
				helpers.DateOf(education.EducationDate),
			)
			info = append(info, fields{
				Label: fmt.Sprintf("学歴 %d", i+1),
				Value: educationValue,
			})
		}
		return info

	case FieldGroupCareer:
		// 職歴情報: すべての職歴記録を表示
		var info []fields
		for i, career := range d.CareerRecords {
			careerValue := fmt.Sprintf("%s（%s - %s）職種: %s",
				helpers.StringOf(career.CompanyName),
				helpers.DateOf(career.StartDate),
				helpers.DateOf(career.EndDate),
				helpers.StringOf(career.JobType),
			)
			info = append(info, fields{
				Label: fmt.Sprintf("職歴 %d", i+1),
				Value: careerValue,
			})
		}
		return info

	case FieldGroupAccident:
		// 事故履歴情報: すべての事故記録を表示
		var info []fields
		for i, accident := range d.AccidentRecords {
			accidentValue := fmt.Sprintf("%s（%s）場所: %s",
				helpers.StringOf(accident.AccidentType),
				helpers.DateOf(accident.AccidentDate),
				helpers.StringOf(accident.AccidentLocation),
			)
			info = append(info, fields{
				Label: fmt.Sprintf("事故履歴 %d", i+1),
				Value: accidentValue,
			})
		}
		return info

	case FieldGroupViolation:
		// 違反履歴情報: すべての違反記録を表示
		var info []fields
		for i, violation := range d.ViolationRecords {
			violationValue := fmt.Sprintf("%s（%s）場所: %s",
				helpers.StringOf(violation.ViolationType),
				helpers.DateOf(violation.ViolationDate),
				helpers.StringOf(violation.ViolationLocation),
			)
			info = append(info, fields{
				Label: fmt.Sprintf("違反履歴 %d", i+1),
				Value: violationValue,
			})
		}
		return info

	default:
		// 未知の情報タイプの場合は空のスライスを返す
		return []fields{}
	}
}
