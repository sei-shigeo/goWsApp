package utils

import (
	"time"
)

// StringOrEmptyは*stringをstringに変換する（nilの場合は空文字列）
func StringOrEmpty(s *string) string {
	if s == nil {
		return ""
	}
	return *s
}

// StringPtrOfはstringを*stringに変換する（空文字列の場合はnilを返す）
func StringPtrOf(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}


// DateFromStringは日付文字列（YYYY-MM-DD形式）を*time.Timeに変換する
// 空文字列の場合はnilを返す
func DateFromString(dateStr string) (*time.Time, error) {
	if dateStr == "" {
		return nil, nil
	}
	t, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		return nil, err
	}
	return &t, nil
}

// PtrOf は、あらゆる型の値をポインタに変換する。
// ただし、型ごとの「ゼロ値」を nil とみなすかは判断が必要。
func PtrOf[T any](v T) *T {
    return &v
}

// ゼロ値（空文字、0、falseなど）なら nil を返す汎用版
func Nullable[T comparable](v T) *T {
    var zero T
    if v == zero {
        return nil
    }
    return &v
}
