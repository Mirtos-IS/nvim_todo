package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"nvim_todo/model"

	_ "github.com/mattn/go-sqlite3"
)

func handleTodo(w http.ResponseWriter, r *http.Request) {
    todoItems := model.GetTodoItems()
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(todoItems)
}

func handleUpdateTodo(w http.ResponseWriter, r *http.Request) {
    var items []model.TodoItems
    b, err := io.ReadAll(r.Body)
    if err != nil {
        panic(err)
    }
    json.Unmarshal(b, &items)
    err = model.UpdateTodoItems(items)
    if err != nil {
        fmt.Println("something went wrong")
        fmt.Println(err)
    }
}

func main() {
    http.HandleFunc("/api/todo", handleTodo)
    http.HandleFunc("/api/todo/update", handleUpdateTodo)

    log.Fatal(http.ListenAndServe(":8080", nil))
}
