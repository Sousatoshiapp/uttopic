package main

import (
	"frich_clone/backend/config"
	"frich_clone/backend/handlers"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	if err := config.InitDB(); err != nil {
		log.Fatalf("Erro ao conectar ao banco de dados: %v", err)
	}
	defer config.DB.Close()

	r := gin.Default()

	r.GET("/ping", handlers.PingHandler)
	r.POST("/users", handlers.CreateUserHandler)
	r.GET("/users/:id", handlers.GetUserHandler)
	r.PUT("/users/:id", handlers.UpdateUserHandler)
	r.DELETE("/users/:id", handlers.DeleteUserHandler)
	r.GET("/users", handlers.ListUsersHandler)

	r.Run(":8080")
}
