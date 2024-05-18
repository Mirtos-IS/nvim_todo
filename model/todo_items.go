package model

import (
	"fmt"
	"nvim_todo/database"

	"github.com/jmoiron/sqlx"
)

type TodoItems struct {
    Id int `json:"id"`
    Title string `json:"title"`
    Ordering int `json:"order"`
    IsMarked bool `json:"is_marked"`
    TodoListId int `json:todo_list_id`
}

func GetTodoItems(listId int) []TodoItems{
    db, err := database.OpenDB()
    if err != nil {
        panic(err)
    }
    defer db.Close()

    rows, err := db.Query("SELECT * FROM todo_items where todo_lists_id=? ORDER BY ordering", listId)
    if err != nil {
        fmt.Println("something went wrong on rows")
        panic(err)
    }

    var items []TodoItems
    for rows.Next() {
        var item TodoItems

        rows.Scan(&item.Id, &item.Title, &item.IsMarked, &item.Ordering)
        items = append(items, item)
    }
    return items
}

func UpdateTodoItems(items []TodoItems) error {
    db, err := database.OpenDB()
    if err != nil {
        return err
    }
    defer db.Close()
    for i, item := range items {
        if item.Id > 0 {
            _, err := db.Exec("UPDATE todo_items SET title=?, is_marked=?, ordering=? todo_lists_id=? where id=?", item.Title, item.IsMarked, i, item.TodoListId,  item.Id)
            if err != nil {
                return err
            }
            continue
        }
        _, err := db.Exec("INSERT INTO todo_items(title, is_marked, ordering, todo_lists_id) VALUES (?,?,?,?)" , item.Title, item.IsMarked, i, item.TodoListId)
        if err != nil {
            return err
        }
    }
    return nil
}

func DeleteTodoItem(id int) error {
    db, err := database.OpenDB()
    if err != nil {
        return err
    }
    defer db.Close()
    _, err = db.Exec("DELETE FROM todo_items WHERE id=?", id)
    if err != nil {
        return err
    }
    return nil
}

func DeleteMultipleItems(ids []int) error {
    db, err := database.OpenDB()
    if err != nil {
        return err
    }
    s, args, err := sqlx.In("DELETE FROM todo_items WHERE id NOT IN (?)", ids)
    if err != nil {
        return err
    }
    _, err = db.Exec(s, args...)
    if err != nil {
        return err
    }
    return nil
}
