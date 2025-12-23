package helpers

import "github.com/jackc/pgx/v5/pgtype"

// StringOfは*stringをstringに変換する
func StringOf(s *string) string {
	if s == nil {
		return "-"
	}
	return *s
}

// DateOfはpgtype.Dateをstringに変換する
func DateOf(date pgtype.Date) string {
	if !date.Valid && date.Time.IsZero() {
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