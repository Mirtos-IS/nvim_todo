package model

import "nvim_todo/database"

type TodoList struct {
    Id int `json:"id"`
    Name string `json:"name"`
}

func GetTodoList() ([]TodoList, error) {
    db, err := database.OpenDB()
    if err != nil {
        return nil, err
    }
    defer db.Close()

    row, err := db.Query("SELECT * FROM todo_lists ORDER BY name")
    if err != nil {
        return nil, err
    }
    todoLists := []TodoList{}
    for row.Next() {
        todoList := TodoList{}
        row.Scan(&todoList.Id, &todoList.Name)
        todoLists = append(todoLists, todoList)
    }
    return todoLists, nil
}

func UpdateTodoList(lists []TodoList) error {
    db, err := database.OpenDB()
    if err != nil {
        return err
    }
    defer db.Close()
    for _, list := range lists {
        if list.Id > 0 {
            _, err := db.Exec("UPDATE todo_lists SET name=? where id=?", list.Name, list.Id)
            if err != nil {
                return err
            }
            continue
        }
        _, err := db.Exec("INSERT INTO todo_lists(name) VALUES (?)" , list.Name)
        if err != nil {
            return err
        }
    }
    return nil
}

func DeleteTodoList(id int) error {
    db, err := database.OpenDB()
    if err != nil {
        return err
    }
    defer db.Close()
    _, err = db.Exec("DELETE FROM todo_lists WHERE id=?", id)
    if err != nil {
        return err
    }
    return nil
}
