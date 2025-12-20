package main

import (
	"context"
	"log"
	"net/http"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
	"github.com/sei-shigeo/webApp/db"
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

// データベース接続
func connectDB() (*pgxpool.Pool, error) {
	dbpool, err := pgxpool.New(context.Background(), os.Getenv("DATABASE_URL"))
	if err != nil {
		return nil, err
	}
	return dbpool, nil
}

func main() {

	// .envファイルを読み込む
	err := godotenv.Load()
	if err != nil {
		log.Fatal(err)
	}

	// データベース接続
	dbpool, err := connectDB()
	if err != nil {
		log.Fatal(err)
	}
	defer dbpool.Close()

	// SQLCクエリインスタンスを初期化
	queries := db.New(dbpool)
	handlers.SetDB(queries)

	mux := http.NewServeMux()

	// 静的ファイルを提供
	mux.Handle("/assets/",
		disableCacheInDevMode(
			http.StripPrefix("/assets",
				http.FileServer(http.Dir("assets")))))

	// ホームページを表示
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		pages.Home().Render(r.Context(), w)
	})
	// 従業員ページを表示
	mux.HandleFunc("GET /employees", handlers.EmployeesHandler)
	mux.HandleFunc("GET /employees/print/{id}", handlers.EmployeesPrintHandler)

	server := http.Server{
		Addr:    ":8080",
		Handler: mux,
	}

	err = server.ListenAndServe()
	if err != nil {
		log.Fatal(err)
	}
}
