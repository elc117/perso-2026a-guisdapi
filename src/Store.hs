module Store where

import Data.IORef
import Data.List (find)
import Types

-- Define que o nosso Store é uma referência mutável para uma lista de livros
type Store = IORef [Book]

-- Cria o banco de dados inicial vazio
newStore :: IO Store
newStore = newIORef []

-- Retorna todos os livros
getAll :: Store -> IO [Book]
getAll store = readIORef store

-- Busca um livro específico pelo ID
getById :: Store -> Int -> IO (Maybe Book)
getById store bid = do
  books <- readIORef store
  return $ find (\b -> bookId b == bid) books

-- Adiciona um novo livro à lista
addBook :: Store -> Book -> IO ()
addBook store book = modifyIORef store (\books -> books ++ [book])

-- Atualiza um livro existente
updateBook :: Store -> Book -> IO Bool
updateBook store updatedBook = do
  books <- readIORef store
  -- Verifica se o livro existe antes de atualizar
  case find (\b -> bookId b == bookId updatedBook) books of
    Nothing -> return False
    Just _  -> do
      modifyIORef store (\bs -> map (\b -> if bookId b == bookId updatedBook then updatedBook else b) bs)
      return True

-- Deleta um livro pelo ID
deleteBook :: Store -> Int -> IO Bool
deleteBook store bid = do
  books <- readIORef store
  case find (\b -> bookId b == bid) books of
    Nothing -> return False
    Just _  -> do
      modifyIORef store (\bs -> filter (\b -> bookId b /= bid) bs)
      return True