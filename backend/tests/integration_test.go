package tests

import (
	"bytes"
	"encoding/json"
	"fmt"
	"frich_clone/backend/config"
	"frich_clone/backend/handlers"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
)

func TestCreateUserIntegration(t *testing.T) {
	// Inicializa a conexão com o banco de dados
	if err := config.InitDB(); err != nil {
		t.Fatalf("Falha ao conectar ao banco de dados: %v", err)
	}
	defer config.DB.Close()

	// Configura o router Gin
	gin.SetMode(gin.TestMode)
	router := gin.New()
	router.POST("/users", handlers.CreateUserHandler)

	// Cria um payload de usuário de teste com email único
	uniqueEmail := fmt.Sprintf("test%d@example.com", time.Now().UnixNano())
	user := handlers.User{
		Name:     "Test User",
		Email:    uniqueEmail,
		Password: "password123",
	}
	payload, _ := json.Marshal(user)

	// Cria uma requisição de teste
	req, _ := http.NewRequest("POST", "/users", bytes.NewBuffer(payload))
	req.Header.Set("Content-Type", "application/json")

	// Executa a requisição
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	// Imprime informações de depuração
	fmt.Printf("Status Code: %d\n", w.Code)
	fmt.Printf("Response Body: %s\n", w.Body.String())

	// Verifica o status code
	if w.Code != http.StatusCreated {
		t.Errorf("Status code esperado %d, mas recebeu %d", http.StatusCreated, w.Code)
	}

	// Verifica a resposta
	var response map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &response)

	if _, exists := response["id"]; !exists {
		t.Errorf("Resposta não contém o campo 'id'")
	}

	// Limpa o dado de teste do banco de dados
	_, err := config.DB.Exec("DELETE FROM users WHERE email = $1", user.Email)
	if err != nil {
		t.Errorf("Falha ao limpar dado de teste: %v", err)
	}

	func TestGetUserIntegration(t *testing.T) {
		// Configuração similar ao TestCreateUserIntegration
		// ...
	
		// Cria um usuário para testar
		createUserResponse := httptest.NewRecorder()
		router.ServeHTTP(createUserResponse, createUserRequest)
	
		var createResponse map[string]interface{}
		json.Unmarshal(createUserResponse.Body.Bytes(), &createResponse)
		createdUserID := int(createResponse["id"].(float64))
	
		// Testa a obtenção do usuário
		req, _ := http.NewRequest("GET", fmt.Sprintf("/users/%d", createdUserID), nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)
	
		if w.Code != http.StatusOK {
			t.Errorf("Status code esperado %d, mas recebeu %d", http.StatusOK, w.Code)
		}
	
		var user User
		json.Unmarshal(w.Body.Bytes(), &user)
		if user.ID != createdUserID {
			t.Errorf("ID do usuário esperado %d, mas recebeu %d", createdUserID, user.ID)
		}
	
		// Limpa o dado de teste
		// ...
	}
}
