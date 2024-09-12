package config

import (
	"os"
)

var (
	DBConnectionString string
)

func LoadEnv() {
	DBConnectionString = os.Getenv("DB_CONNECTION_STRING")
	if DBConnectionString == "" {
		DBConnectionString = "host=localhost port=5432 dbname=frich_clone sslmode=disable"
	}
}
