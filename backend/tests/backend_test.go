package tests

import (
	"bytes"
	"encoding/json"
	"frich_clone/backend/config"
	"frich_clone/backend/handlers"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func TestMain(m *testing.M) {
	// Inicializa o banco de dados antes de executar os testes
	if err := config.InitDB(); err != nil {
		panic("Failed to connect to database: " + err.Error())
	}
	defer config.DB.Close()

	// Executa os testes
	m.Run()
}

func TestPingEndpoint(t *testing.T) {
	// ... (mantenha o código existente)
}

func TestCreateUserEndpoint(t *testing.T) {
	// Configura o Gin para o modo de teste
	gin.SetMode(gin.TestMode)

	// Cria um novo router Gin
	router := gin.New()
	router.POST("/users", handlers.CreateUserHandler)

	// Cria um payload JSON para o novo usuário
	payload := []byte(`{"name":"Test User","email":"test@example.com","password":"password123"}`)

	// Cria uma nova requisição de teste
	req, err := http.NewRequest("POST", "/users", bytes.NewBuffer(payload))
	if err != nil {
		t.Fatal(err)
	}
	req.Header.Set("Content-Type", "application/json")

	// Cria um ResponseRecorder para gravar a resposta
	rr := httptest.NewRecorder()

	// Serve a requisição ao router
	router.ServeHTTP(rr, req)

	// Verifica o status code da resposta
	if status := rr.Code; status != http.StatusCreated {
		t.Errorf("handler retornou status code errado: obteve %v, esperava %v",
			status, http.StatusCreated)
	}

	// Analisa a resposta JSON
	var response map[string]interface{}
	json.Unmarshal(rr.Body.Bytes(), &response)

	// Verifica se o ID do usuário foi retornado
	if _, exists := response["id"]; !exists {
		t.Errorf("resposta não contém o campo 'id'")
	}
}
