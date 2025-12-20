package main

import (
	"log"
	"net/http"

	"github.com/sei-shigeo/webApp/handlers"
	"github.com/sei-shigeo/webApp/views/pages"
)

var dev = true

// 開発モードではキャッシュを無効にする
func disableCacheInDevMode(next http.Handler) http.Handler {
	if !dev {
		return next
	}
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Cache-Control", "no-store")
		next.ServeHTTP(w, r)
	})
}

func main() {

	mux := http.NewServeMux()

	mux.Handle("/assets/",
		disableCacheInDevMode(
			http.StripPrefix("/assets",
				http.FileServer(http.Dir("assets")))))

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		pages.Home().Render(r.Context(), w)
	})
	mux.HandleFunc("GET /employees", handlers.EmployeesHandler)
	mux.HandleFunc("GET /employees/print/{id}", handlers.EmployeesPrintHandler)

	server := http.Server{
		Addr:    ":8080",
		Handler: mux,
	}

	err := server.ListenAndServe()
	if err != nil {
		log.Fatal(err)
	}
}
