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
}

func GetTodoItems() []TodoItems{
    db, err := database.OpenDB()
    if err != nil {
        panic(err)
    }
    defer db.Close()

    rows, err := db.Query("SELECT * FROM todo_items ORDER BY ordering")
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
    var ids []int
    for i, item := range items {
        if item.Id > 0 {
            ids = append(ids, item.Id)
            _, err := db.Exec("UPDATE todo_items SET title=?, is_marked=?, ordering=? where id=?", item.Title, item.IsMarked, i, item.Id)
            if err != nil {
                return err
            }
            continue
        }
        res, err := db.Exec("INSERT INTO todo_items(title, is_marked, ordering) VALUES (?,?,?)" , item.Title, item.IsMarked, i)
        if err != nil {
            return err
        }
        id, _ := res.LastInsertId()
        ids = append(ids, int(id))
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
