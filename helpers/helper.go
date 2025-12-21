package helpers

import "github.com/jackc/pgx/v5/pgtype"

func StringOf(s *string) string {
	if s == nil {
		return "-"
	}
	return *s
}

func DateOf(date pgtype.Date) string {
	if !date.Valid && date.Time.IsZero() {
		return "-"
	}
	return date.Time.Format("2006-01-02")
}
