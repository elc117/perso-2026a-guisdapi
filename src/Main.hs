{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Scotty 
import Network.Wai.Middleware.RequestLogger (logStdoutDev) 
import Network.Wai.Middleware.Cors (simpleCors)
import Control.Monad.IO.Class (liftIO) 
import Network.HTTP.Types.Status (status404) 
import Data.Aeson (object, (.=))
import Network.HTTP.Types.Status (badRequest400)

import Types hiding (status)
import Logic
import Store

-- Módulo principal do servidor Web (usando Scotty)
-- Agrega as rotas da API e delega as validações para a camada lógica (pura)
-- e as operações de banco de dados para a camada Store (impura)

main :: IO ()
main = do
  store <- newStore
  scotty 3000 $ do
    middleware logStdoutDev
    middleware simpleCors

    -- Rota para servir o frontend
    get "/" $ file "index.html"
    
    get "/healthz" $ do
        text "OK"

    get "/books" $ do
      books <- liftIO $ getAll store
      json books -- Serialização segura via Aeson

    get "/books/filter" $ do
      minStar <- queryParam "minRating"
      books   <- liftIO $ getAll store
      json (filterByMinRating minStar books)

    get "/books/:id" $ do
      bid <- pathParam "id"
      result <- liftIO $ getById store bid
      case result of
        Nothing -> do
          status status404
          json $ object ["error" .= ("Livro não encontrado" :: String)]
        Just b  -> json b

    get "/stats" $ do
        -- 1. Busca todos os livros no banco de dados (Efeito Colateral / IO)
        books <- liftIO $ getAll "books.db"
        
        -- 2. Passa os livros para a função pura (Sem IO)
        let stats = calculateStats books
        
        -- 3. Devolve como JSON
        json stats

    post "/books" $ do
        newBook <- jsonData :: ActionM Book
        
        -- Avalia o resultado da função pura de validação
        case validateBook newBook of
            Left erroMsg -> do
                -- Se caiu em alguma regra, devolve erro 400 (Bad Request)
                status badRequest400 
                json $ object ["error" .= erroMsg]
                
            Right bookValido -> do
                -- Se a lógica aprovou, insere no SQLite
                liftIO $ addBook "books.db" bookValido
                json bookValido

    put "/books/:id" $ do
        bid <- pathParam "id"
        updatedBook <- jsonData :: ActionM Book
        -- Força o ID da URL no objeto para garantir consistência
        let bookToSave = updatedBook { bookId = bid }
        
        case validateBook bookToSave of
            Left erroMsg -> do
                status badRequest400
                json $ object ["error" .= erroMsg]
            Right b -> do
                liftIO $ updateBook "books.db" b
                json b

    
    delete "/books/:id" $ do
      bid <- pathParam "id"
      ok  <- liftIO $ deleteBook store bid
      if ok
        then json $ object ["message" .= ("Livro removido" :: String)]
        else do
          status status404
          json $ object ["error" .= ("Livro não encontrado" :: String)]