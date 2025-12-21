package handlers

import (
	"net/http"

	"github.com/sei-shigeo/webApp/db"
)

type App struct {
	db  *db.Queries
	mux *http.ServeMux
	dev bool // 開発モードフラグ
}

func NewApp(db *db.Queries, mux *http.ServeMux, dev bool) *App {
	return &App{db: db, mux: mux, dev: dev}
}

// disableCacheInDevMode は開発モード時にキャッシュを無効化するミドルウェア
func (a *App) disableCacheInDevMode(next http.Handler) http.Handler {
	if !a.dev {
		return next
	}
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Cache-Control", "no-store")
		next.ServeHTTP(w, r)
	})
}