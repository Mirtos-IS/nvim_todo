package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"nvim_todo/model"
	"strconv"

	_ "github.com/mattn/go-sqlite3"
)

func handleTodo(w http.ResponseWriter, r *http.Request) {
    rawId := r.URL.Path[len("/api/todo/"):]
    id, err := strconv.Atoi(rawId)
    if err != nil {
        fmt.Println(err)
        http.Error(w, "invalid id on url", http.StatusUnprocessableEntity)
    }
    todoItems := model.GetTodoItems(id)
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
        http.Error(w, "something went wrong", http.StatusInternalServerError)
    }
}

func handleDeleteTodo(w http.ResponseWriter, r *http.Request) {
    var data map[string]int
    b, _ := io.ReadAll(r.Body)
    json.Unmarshal(b, &data)

    itemId := data["item_id"]
    model.DeleteTodoItem(itemId)
}

func handleList(w http.ResponseWriter, r *http.Request) {
    todoLists, err := model.GetTodoList()
    if err != nil {
        fmt.Println(err)
        http.Error(w, "couldn't get list", http.StatusInternalServerError)
    }
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(todoLists)

}

func handleUpdateList(w http.ResponseWriter, r *http.Request) {
    var lists []model.TodoList
    b, err := io.ReadAll(r.Body)
    if err != nil {
        panic(err)
    }
    json.Unmarshal(b, &lists)
    err = model.UpdateTodoList(lists)
    if err != nil {
        fmt.Println(err)
        http.Error(w, "something went wrong", http.StatusInternalServerError)
    }
}

func handleDeleteList(w http.ResponseWriter, r *http.Request) {
    var data map[string]int
    b, _ := io.ReadAll(r.Body)
    json.Unmarshal(b, &data)

    listId := data["list_id"]
    err := model.DeleteTodoList(listId)
    if err != nil {
        fmt.Println(err)
    }
}

func main() {
    http.HandleFunc("/api/todo", handleTodo)
    http.HandleFunc("/api/todo/update", handleUpdateTodo)
    http.HandleFunc("/api/todo/delete", handleDeleteTodo)

    http.HandleFunc("/api/list", handleList)
    http.HandleFunc("/api/list/update", handleUpdateList)
    http.HandleFunc("/api/list/delete", handleDeleteList)

    log.Fatal(http.ListenAndServe(":8080", nil))
}
