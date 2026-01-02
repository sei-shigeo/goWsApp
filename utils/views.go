package utils

import "time"

// imageUrlOrEmptyは*stringを画像URLに変換する（nilの場合はデフォルト画像）
func ImageUrlOrEmpty(imageUrl *string) string {
	if imageUrl == nil {
		return "./assets/images/150x150.png"
	}
	return *imageUrl
}

// DisplayStringは*stringを表示用文字列に変換する（nilまたは空文字列の場合は"未設定"）
func DisplayString(s *string) string {
	if s == nil || *s == "" {
		return "未設定"
	}
	return *s
}
// DateOrEmptyは*time.Timeを文字列（YYYY-MM-DD形式）に変換する（nilの場合は空文字列）
func DateOf(date *time.Time) string {
	if date == nil || date.IsZero() {
		return ""
	}
	return date.Format("2006-01-02")
}