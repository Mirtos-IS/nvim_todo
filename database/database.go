package database

import (
	"github.com/jmoiron/sqlx"
)

func OpenDB() (*sqlx.DB, error){
    db, err := sqlx.Open("sqlite3", "database/nvim_todo.db")
    return db, err
}
