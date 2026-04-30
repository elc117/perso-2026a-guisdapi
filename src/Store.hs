{-# LANGUAGE OverloadedStrings #-}

module Store where

import Database.SQLite.Simple
import Types

type Store = String

-- Inicializa o banco e cria a tabela se não existir
newStore :: IO Store
newStore = do
    let dbPath = "books.db"
    conn <- open dbPath
    execute_ conn "CREATE TABLE IF NOT EXISTS books (bookId INTEGER PRIMARY KEY, title TEXT, totalPages INTEGER, readPages INTEGER, rating INTEGER, notes TEXT, status TEXT)"
    close conn
    return dbPath

getAll :: Store -> IO [Book]
getAll dbPath = do
    conn <- open dbPath
    books <- query_ conn "SELECT bookId, title, totalPages, readPages, rating, notes, status FROM books"
    close conn
    return books

getById :: Store -> Int -> IO (Maybe Book)
getById dbPath bid = do
    conn <- open dbPath
    books <- query conn "SELECT bookId, title, totalPages, readPages, rating, notes, status FROM books WHERE bookId = ?" (Only bid) :: IO [Book]
    close conn
    case books of
        [book] -> return (Just book)
        _      -> return Nothing

addBook :: Store -> Book -> IO ()
addBook dbPath book = do
    conn <- open dbPath
    execute conn "INSERT INTO books (bookId, title, totalPages, readPages, rating, notes, status) VALUES (?, ?, ?, ?, ?, ?, ?)" book
    close conn

updateBook :: Store -> Book -> IO Bool
updateBook dbPath book = do
    conn <- open dbPath
    execute conn "UPDATE books SET title = ?, totalPages = ?, readPages = ?, rating = ?, notes = ?, status = ? WHERE bookId = ?" 
        (title book, totalPages book, readPages book, rating book, notes book, status book, bookId book)
    -- Verifica se alguma linha foi afetada
    changesCount <- changes conn
    close conn
    return (changesCount > 0)

deleteBook :: Store -> Int -> IO Bool
deleteBook dbPath bid = do
    conn <- open dbPath
    execute conn "DELETE FROM books WHERE bookId = ?" (Only bid)
    changesCount <- changes conn
    close conn
    return (changesCount > 0)