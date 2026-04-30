{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Scotty
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Control.Monad.IO.Class (liftIO)
import Network.HTTP.Types.Status (status404)
import Data.Aeson (object, (.=))

import Types
import Logic
import Store

main :: IO ()
main = do
  store <- newStore
  scotty 3000 $ do
    middleware logStdoutDev

    get "/books" $ do
      books <- liftIO $ getAll store
      json books -- Serialização segura via Aeson

    get "/books/:id" $ do
      bid <- pathParam "id"
      result <- liftIO $ getById store bid
      case result of
        Nothing -> do
          status status404
          json $ object ["error" .= ("Livro não encontrado" :: String)]
        Just b  -> json b

    -- POST reformulado: Recebe o payload JSON completo e faz o parse automático
    post "/books" $ do
      bookReq <- jsonData
      liftIO $ addBook store bookReq
      json bookReq

    put "/books/:id" $ do
      bid <- pathParam "id"
      updated <- jsonData
      -- Garante que a entidade atualizada respeite o ID da URL
      let bookToUpdate = updated { bookId = bid }
      ok <- liftIO $ updateBook store bookToUpdate
      if ok
        then json bookToUpdate
        else do
          status status404
          json $ object ["error" .= ("Livro não encontrado" :: String)]

    delete "/books/:id" $ do
      bid <- pathParam "id"
      ok  <- liftIO $ deleteBook store bid
      if ok
        then json $ object ["message" .= ("Livro removido" :: String)]
        else do
          status status404
          json $ object ["error" .= ("Livro não encontrado" :: String)]

    get "/books/filter" $ do
      minStar <- queryParam "minRating"
      books   <- liftIO $ getAll store
      json (filterByMinRating minStar books)