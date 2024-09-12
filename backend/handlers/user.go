package handlers

import (
	"database/sql"
	"frich_clone/backend/config"
	"log"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/lib/pq"
	"golang.org/x/crypto/bcrypt"
)

type User struct {
	ID       int    `json:"id"`
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password,omitempty"`
}

func CreateUserHandler(c *gin.Context) {
	var user User
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Hash da senha
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erro ao processar a senha"})
		return
	}

	query := `INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING id`
	err = config.DB.QueryRow(query, user.Name, user.Email, string(hashedPassword)).Scan(&user.ID)
	if err != nil {
		if pqErr, ok := err.(*pq.Error); ok && pqErr.Code.Name() == "unique_violation" {
			c.JSON(http.StatusConflict, gin.H{"error": "Email já está em uso"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Erro ao criar usuário"})
		}
		return
	}

	c.JSON(http.StatusCreated, gin.H{"id": user.ID, "message": "Usuário criado com sucesso"})
}

func GetUserHandler(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		log.Printf("ID inválido fornecido: %v", c.Param("id"))
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID inválido"})
		return
	}

	var user User
	err = config.DB.QueryRow("SELECT id, name, email FROM users WHERE id = $1", id).Scan(&user.ID, &user.Name, &user.Email)
	if err != nil {
		if err == sql.ErrNoRows {
			log.Printf("Usuário não encontrado para o ID: %d", id)
			c.JSON(http.StatusNotFound, gin.H{"error": "Usuário não encontrado"})
		} else {
			log.Printf("Erro ao buscar usuário: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Erro ao buscar usuário"})
		}
		return
	}

	log.Printf("Usuário encontrado: %+v", user)
	c.JSON(http.StatusOK, user)
}

func UpdateUserHandler(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID inválido"})
		return
	}

	var user User
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Verifica se o usuário existe
	var existingUser User
	err = config.DB.QueryRow("SELECT id FROM users WHERE id = $1", id).Scan(&existingUser.ID)
	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Usuário não encontrado"})
		return
	} else if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erro ao verificar usuário"})
		return
	}

	_, err = config.DB.Exec("UPDATE users SET name = $1, email = $2 WHERE id = $3", user.Name, user.Email, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erro ao atualizar usuário"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Usuário atualizado com sucesso"})
}

func DeleteUserHandler(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID inválido"})
		return
	}

	result, err := config.DB.Exec("DELETE FROM users WHERE id = $1", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erro ao deletar usuário"})
		return
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erro ao verificar deleção"})
		return
	}

	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Usuário não encontrado"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Usuário deletado com sucesso"})
}

func ListUsersHandler(c *gin.Context) {
	rows, err := config.DB.Query("SELECT id, name, email FROM users")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erro ao listar usuários"})
		return
	}
	defer rows.Close()

	var users []User
	for rows.Next() {
		var user User
		if err := rows.Scan(&user.ID, &user.Name, &user.Email); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Erro ao ler dados dos usuários"})
			return
		}
		users = append(users, user)
	}

	c.JSON(http.StatusOK, users)
}
