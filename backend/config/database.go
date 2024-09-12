package config

import (
	"database/sql"
	"fmt"

	_ "github.com/lib/pq"
)

var DB *sql.DB

func InitDB() error {
	LoadEnv() // Carrega as variáveis de ambiente
	var err error
	DB, err = sql.Open("postgres", DBConnectionString)
	if err != nil {
		return err
	}

	if err = DB.Ping(); err != nil {
		return err
	}

	fmt.Println("Conexão com o banco de dados estabelecida com sucesso")
	return nil
}
