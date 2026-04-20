{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Scotty
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Control.Monad.IO.Class (liftIO)
import Data.IORef
import Data.List (intercalate)
import Data.String (fromString)
import Network.HTTP.Types.Status (status404)

import Types
import Logic
import Store

-- Converte um Book para string JSON
bookToJson :: Book -> String
bookToJson b = "{"
  ++ "\"bookId\":"    ++ show (bookId b)    ++ ","
  ++ "\"title\":"     ++ show (title b)     ++ ","
  ++ "\"totalPages\":" ++ show (totalPages b) ++ ","
  ++ "\"readPages\":"  ++ show (readPages b)  ++ ","
  ++ "\"rating\":"    ++ show (rating b)    ++ ","
  ++ "\"notes\":"     ++ show (notes b)     ++ ","
  ++ "\"progress\":"  ++ show (calcProgress b)
  ++ "}"

-- Converte lista de Books para JSON array
booksToJson :: [Book] -> String
booksToJson books = "[" ++ intercalate "," (map bookToJson books) ++ "]"

main :: IO ()
main = do
  store <- newStore
  scotty 3000 $ do
    middleware logStdoutDev

    -- GET /books — lista todos
    get "/books" $ do
      books <- liftIO $ getAll store
      setHeader "Content-Type" "application/json"
      text $ fromString $ booksToJson books

    -- GET /books/:id — busca por ID
    get "/books/:id" $ do
      bid <- param "id"
      result <- liftIO $ getById store bid
      setHeader "Content-Type" "application/json"
      case result of
        Nothing -> do
          status status404
          text "{\"error\":\"Livro não encontrado\"}"
        Just b  -> text $ fromString $ bookToJson b

    -- POST /books — adiciona livro
    post "/books" $ do
      bid      <- param "bookId"
      t        <- param "title"
      tp       <- param "totalPages"
      rp       <- param "readPages"
      rat      <- param "rating"
      ns       <- param "notes"
      let book = Book bid t tp rp rat ns
      liftIO $ addBook store book
      setHeader "Content-Type" "application/json"
      text $ fromString $ bookToJson book

    -- PUT /books/:id — atualiza livro
    put "/books/:id" $ do
      bid <- param "id"
      t   <- param "title"
      tp  <- param "totalPages"
      rp  <- param "readPages"
      rat <- param "rating"
      ns  <- param "notes"
      let updated = Book bid t tp rp rat ns
      ok <- liftIO $ updateBook store updated
      setHeader "Content-Type" "application/json"
      if ok
        then text $ fromString $ bookToJson updated
        else do
          status status404
          text "{\"error\":\"Livro não encontrado\"}"

    -- DELETE /books/:id — remove livro
    delete "/books/:id" $ do
      bid <- param "id"
      ok  <- liftIO $ deleteBook store bid
      setHeader "Content-Type" "application/json"
      if ok
        then text "{\"message\":\"Livro removido\"}"
        else do
          status status404
          text "{\"error\":\"Livro não encontrado\"}"

    -- GET /books/filter?minRating=4 — filtra por avaliação
    get "/books/filter" $ do
      minStar <- param "minRating"
      books   <- liftIO $ getAll store
      setHeader "Content-Type" "application/json"
      text $ fromString $ booksToJson (filterByMinRating minStar books)