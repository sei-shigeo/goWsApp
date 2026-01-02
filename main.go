package main

import (
	"database/sql"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
	_ "github.com/mattn/go-sqlite3"
	"github.com/sei-shigeo/webApp/db"
	"github.com/sei-shigeo/webApp/handlers"
)

// データベース接続
func connectDB() (*sql.DB, error) {
	dbPath := os.Getenv("DATABASE_URL")
	if dbPath == "" {
		dbPath = "wsapp.db"
	}
	database, err := sql.Open("sqlite3", dbPath)
	if err != nil {
		return nil, err
	}
	if err := database.Ping(); err != nil {
		return nil, err
	}
	return database, nil
}

func main() {

	// .envファイルを読み込む
	err := godotenv.Load()
	if err != nil {
		log.Fatal(err)
	}

	// データベース接続
	database, err := connectDB()
	if err != nil {
		log.Fatal(err)
	}
	defer database.Close()

	// SQLCクエリインスタンスを初期化
	dbQueries := db.New(database)
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
