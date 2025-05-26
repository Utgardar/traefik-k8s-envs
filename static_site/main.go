package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	env := getEnvOrDefault("ENVIRONMENT", "unknown")
	secret := getEnvOrDefault("SECRET", "no-secret-provided")
	port := getEnvOrDefault("PORT", "8080")

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("Received request from %s for %s", r.RemoteAddr, r.URL.Path)
		html := fmt.Sprintf(`
<!DOCTYPE html>
<html>
<body>
    <div>
        Hello World!<br>
        I am on <b>%s</b>.<br>
        And this is my <b>%s</b>.
    </div>
</body>
</html>
`, env, secret)

		w.Header().Set("Content-Type", "text/html")
		w.WriteHeader(http.StatusOK)
		fmt.Fprint(w, html)
	})

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprint(w, "OK")
	})

	serverAddr := ":" + port
	log.Printf("Starting server on %s", serverAddr)
	log.Printf("Environment: %s", env)
	if err := http.ListenAndServe(serverAddr, nil); err != nil {
		log.Fatalf("Server error: %v", err)
	}
}

func getEnvOrDefault(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}
