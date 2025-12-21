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
)


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
	dbQueries := db.New(dbpool)
	mux := http.NewServeMux()

	// アプリケーションインスタンスを作成(開発モード: true, 本番モード: false)
	dev := true
	app := handlers.NewApp(dbQueries, mux, dev)


	// ルーティングを設定(静的ファイルも含む)
	if err := app.SetupRouters(); err != nil {
		log.Fatal(err)
	}

	server := http.Server{
		Addr:    ":8080",
		Handler: mux,
	}

	err = server.ListenAndServe()
	if err != nil {
		log.Fatal(err)
	}
}
