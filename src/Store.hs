module Store where

import Data.IORef
import Data.List (find)
import Types

type Store = IORef [Book]

newStore :: IO Store
newStore = newIORef []

getAll :: Store -> IO [Book]
getAll store = readIORef store

getById :: Store -> Int -> IO (Maybe Book)
getById store bid = do
  books <- readIORef store
  return $ find (\b -> bookId b == bid) books

-- Correção: Uso de modifyIORef' (estrito) para evitar memory leak
addBook :: Store -> Book -> IO ()
addBook store book = modifyIORef' store (book :)

updateBook :: Store -> Book -> IO Bool
updateBook store updatedBook = do
  books <- readIORef store
  let (newBooks, found) = foldr step ([], False) books
  if found
    then writeIORef store newBooks >> return True
    else return False
  where
    step b (acc, f)
      | bookId b == bookId updatedBook = (updatedBook : acc, True)
      | otherwise                      = (b : acc, f)

-- Correção: Uso de modifyIORef' (estrito)
deleteBook :: Store -> Int -> IO Bool
deleteBook store bid = do
  books <- readIORef store
  case find (\b -> bookId b == bid) books of
    Nothing -> return False
    Just _  -> do
      modifyIORef' store (\bs -> filter (\b -> bookId b /= bid) bs)
      return True