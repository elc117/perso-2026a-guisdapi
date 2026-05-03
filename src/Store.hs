{-# LANGUAGE OverloadedStrings #-}

module Store where

import Database.SQLite.Simple
import Types

type Store = String

-- Funções monádicas que lidam com Efeitos Colaterais (assinatura 'IO').
-- Fazem a fronteira entre a pureza do Haskell e o mundo externo (Banco de Dados).

-- Inicializa o banco e cria a tabela se não existir
newStore :: IO Store
newStore = do
    let dbPath = "books.db"
    conn <- open dbPath
    execute_ conn "CREATE TABLE IF NOT EXISTS books (bookId INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, author TEXT, publishYear INTEGER, genre TEXT, totalPages INTEGER, readPages INTEGER, rating INTEGER, notes TEXT, status TEXT)"
    close conn
    return dbPath

getAll :: Store -> IO [Book]
getAll dbPath = do
    conn <- open dbPath
    books <- query_ conn "SELECT bookId, title, author, publishYear, genre, totalPages, readPages, rating, notes, status FROM books"
    close conn
    return books

getById :: Store -> Int -> IO (Maybe Book)
getById dbPath bid = do
    conn <- open dbPath
    books <- query conn "SELECT bookId, title, author, publishYear, genre, totalPages, readPages, rating, notes, status FROM books WHERE bookId = ?" (Only bid) :: IO [Book]
    close conn
    case books of
        [book] -> return (Just book)
        _      -> return Nothing

addBook :: FilePath -> Book -> IO ()
addBook dbPath book = do
    conn <- open dbPath
    execute conn 
        "INSERT INTO books (title, author, publishYear, genre, totalPages, readPages, rating, notes, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)" 
        (title book, author book, publishYear book, genre book, totalPages book, readPages book, rating book, notes book, show $ status book)
    close conn

updateBook :: FilePath -> Book -> IO ()
updateBook dbPath book = do
    conn <- open dbPath
    execute conn 
        "UPDATE books SET title = ?, author = ?, publishYear = ?, genre = ?, totalPages = ?, readPages = ?, rating = ?, status = ?, notes = ? WHERE bookId = ?" 
        (title book, author book, publishYear book, genre book, totalPages book, readPages book, rating book, show $ status book, notes book, bookId book)
    close conn

deleteBook :: Store -> Int -> IO Bool
deleteBook dbPath bid = do
    conn <- open dbPath
    execute conn "DELETE FROM books WHERE bookId = ?" (Only bid)
    changesCount <- changes conn
    close conn
    return (changesCount > 0)