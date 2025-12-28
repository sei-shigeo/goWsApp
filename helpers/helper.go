package helpers

import (
	"time"

	"github.com/jackc/pgx/v5/pgtype"
)

// StringOfは*stringをstringに変換する
func StringOf(s *string) string {
	if s == nil {
		return "未設定"
	}
	return *s
}

// DateOfはpgtype.Dateをstringに変換する
func DateOf(date pgtype.Date) string {
	if !date.Valid || date.Time.IsZero() {
		return ""
	}
	return date.Time.Format("2006-01-02")
}

// ImageUrlOfは*stringをstringに変換する
func ImageUrlOf(imageUrl *string) string {
	if imageUrl == nil {
		return "https://placehold.jp/150x150.png"
	}
	return *imageUrl
}

// StringPtrOfはstringを*stringに変換する（空文字列の場合はnilを返す）
func StringPtrOf(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}

// UI表示用
func DisplayString(s *string) string {
	if s == nil || *s == "" {
		return "未設定"
	}
	return *s
}

// データ用（nilは空文字にするだけ、またはそのまま使う）
func StringOrEmpty(s *string) string {
	if s == nil {
		return ""
	}
	return *s
}

// DateFromStringPtrは*string（日付文字列）をpgtype.Dateに変換する
// 空文字列やnilの場合はValid: falseのpgtype.Dateを返す
func DateFromStringPtr(dateStr *string) (pgtype.Date, error) {
	if dateStr == nil || *dateStr == "" {
		return pgtype.Date{Valid: false}, nil
	}
	t, err := time.Parse("2006-01-02", *dateStr)
	if err != nil {
		return pgtype.Date{Valid: false}, err
	}
	return pgtype.Date{Time: t, Valid: true}, nil
}
