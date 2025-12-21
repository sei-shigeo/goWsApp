package handlers

import (
	"net/http"

	"github.com/sei-shigeo/webApp/views/pages"
)

func (a *App) SetupRouters() error {
	// 静的ファイルを提供 (開発モード時ではキャッシュを無効にする)
	a.mux.Handle("/assets/",
		a.disableCacheInDevMode(
			http.StripPrefix("/assets",
				http.FileServer(http.Dir("assets")))))

	// ホームページを表示
	a.mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		pages.Home().Render(r.Context(), w)
	})

	// 従業員関連のルーティング
	if err := a.EmployeesRouter(); err != nil {
		return err
	}

	return nil
}
