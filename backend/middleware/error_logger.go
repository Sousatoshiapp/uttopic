package middleware

import (
	"log"

	"github.com/gin-gonic/gin"
)

func ErrorLogger() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()

		for _, err := range c.Errors {
			log.Printf("Erro: %v", err)
		}
	}
}
